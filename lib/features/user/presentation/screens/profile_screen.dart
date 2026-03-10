import 'package:daeja/core/utils/logger.dart';
import 'package:daeja/core/utils/phone_number_utils.dart';
import 'package:daeja/features/user/presentation/providers/user_provider.dart';
import 'package:daeja/features/user/presentation/screens/vehicle_edit_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../presentation/providers/main_screen_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../reservation/domain/models/reservation.dart'
    as reservation_domain;
import '../../../reservation/presentation/providers/user_reservation_provider.dart';
import '../../domain/models/user.dart';
import '../../domain/models/vehicle.dart';
import 'terms_screen.dart';
import 'vehicle_add_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isTogglingNotification = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    // Watch real-time reservations
    AsyncValue<List<reservation_domain.Reservation>>? reservationsAsync;
    if (currentUser != null) {
      reservationsAsync = ref.watch(myReservationsProvider(currentUser.uid));
    }

    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: '프로필'.text.size(18).bold.make(),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Section
              _buildUserProfile(currentUser),
              SizedBox(height: height * 0.015),

              // Reservation Count - pass real data
              if (currentUser != null)
                _buildReservationCount(reservationsAsync),
              SizedBox(height: height * 0.015),

              // Vehicle List
              if (currentUser != null) _buildMyVehicleList(),
              SizedBox(height: height * 0.015),

              // Settings
              Column(
                children: [
                  // 로그인 시에만 표시
                  if (currentUser != null) ...[
                    // Notification
                    _buildToggleSetting(
                      Icons.notifications_outlined,
                      '알림 설정',
                      currentUser.notificationsEnabled,
                      isEnabled: !_isTogglingNotification,
                      onChanged: (bool value) async {
                        if (_isTogglingNotification) return;

                        setState(() {
                          _isTogglingNotification = true;
                        });

                        Log.d('[ProfileScreen] 알림 설정 변경 시작: $value');

                        try {
                          await ref
                              .read(userProvider.notifier)
                              .toggleNotifications(value);

                          Log.d('[ProfileScreen] 알림 설정 변경 완료: $value');

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value ? '알림이 켜졌습니다' : '알림이 꺼졌습니다',
                                ),
                                backgroundColor: value
                                    ? Colors.green
                                    : Colors.grey,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          Log.e('[ProfileScreen] 알림 설정 변경 실패', e);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('알림 설정 변경에 실패했습니다: $e'),
                                backgroundColor: Colors.redAccent,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isTogglingNotification = false;
                            });
                          }
                        }
                      },
                    ),
                    // Reservation List
                    _buildMenuItem(
                      Icons.description_outlined,
                      '이용 내역',
                      onTap: () {
                        // MainScreen의 "내역" 탭(인덱스 2)으로 전환
                        ref.read(mainScreenTabIndexProvider.notifier).setTab(2);
                        // 프로필 화면 닫기
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ],
              ).pSymmetric(h: 16, v: 8).box.color(Colors.white).make(),
              SizedBox(height: height * 0.015),

              // Policy
              Column(
                children: [
                  // Terms of Service
                  _buildMenuItem(
                    Icons.info_outline,
                    '이용 약관',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsScreen(
                            title: '이용 약관',
                            assetPath: 'assets/terms/terms_of_service.html',
                          ),
                        ),
                      );
                    },
                  ),

                  // Privacy Policy
                  _buildMenuItem(
                    Icons.info_outline,
                    '개인정보 처리방침',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsScreen(
                            title: '개인정보 처리방침',
                            assetPath: 'assets/terms/privacy_policy.html',
                          ),
                        ),
                      );
                    },
                  ),

                  // App Version
                  _buildAppVersion(),
                ],
              ).pSymmetric(h: 16, v: 8).box.color(Colors.white).make(),
              SizedBox(height: height * 0.015),

              // Logout (only show when logged in)
              if (currentUser != null) _buildLogout(),

              // Account Deletion (small link)
              if (currentUser != null) _buildDeleteAccountLink(),

              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(User? user) {
    if (user == null) {
      // Not logged in - show login button
      return Center(
        child: Column(
          children: [
            Icon(Icons.person_outline, size: 60, color: Colors.grey.shade400),
            SizedBox(height: 16),
            '로그인이 필요합니다'.text.size(18).color(Colors.grey.shade700).bold.make(),
            SizedBox(height: 8),
            '로그인하고 더 많은 기능을 이용해보세요'.text
                .size(14)
                .color(Colors.grey.shade500)
                .make(),
            SizedBox(height: 20),
            // Login button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignInScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: '로그인'.text.size(16).color(Colors.white).bold.make(),
              ),
            ),
          ],
        ),
      ).pSymmetric(v: 40).box.color(Colors.white).make();
    }

    // Logged in - show user info
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              // profile image
              Icon(
                    Icons.person_2_outlined,
                    size: 60,
                    color: Colors.grey.shade700,
                  )
                  .p(12)
                  .box
                  .roundedFull
                  .color(Colors.grey.shade100)
                  .make()
                  .p(4)
                  .box
                  .roundedFull
                  .color(Colors.white)
                  .outerShadowMd
                  .make(),

              SizedBox(height: 12),

              // name
              (user.name ?? '').text.size(20).bold.make(),

              SizedBox(height: 4),

              // phone number
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  SizedBox(width: 4),
                  PhoneNumberUtils.globalToKorea(
                    user.phone,
                  ).text.size(14).color(Colors.grey.shade700).make(),
                  SizedBox(width: 4),
                  Icon(
                    Icons.check_circle_outline_outlined,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                ],
              ),

              SizedBox(height: 8),

              // edit button
              GestureDetector(
                onTap: () => _showEditNameDialog(user),
                child: '프로필 수정'.text
                    .size(12)
                    .make()
                    .pSymmetric(v: 8, h: 12)
                    .box
                    .roundedSM
                    .color(Colors.grey.shade200)
                    .make(),
              ),
            ],
          ),
        ],
      ),
    ).pSymmetric(v: 24).box.color(Colors.white).make();
  }

  Widget _buildReservationCount(
    AsyncValue<List<reservation_domain.Reservation>>? reservationsAsync,
  ) {
    // Handle null case (no user logged in)
    if (reservationsAsync == null) {
      return _buildCountsDisplay(0, 0, 0);
    }

    // Handle AsyncValue states
    return reservationsAsync.when(
      data: (reservations) {
        // Calculate real counts
        final total = reservations.length;
        final completed = reservations
            .where(
              (r) => r.status == reservation_domain.ReservationStatus.completed,
            )
            .length;
        final cancelled = reservations
            .where(
              (r) => r.status == reservation_domain.ReservationStatus.cancelled,
            )
            .length;

        return _buildCountsDisplay(total, completed, cancelled);
      },
      loading: () => _buildCountsDisplay(0, 0, 0), // Show 0 while loading
      error: (error, stack) {
        Log.e('예약 정보 로드 실패', error);
        return _buildCountsDisplay(0, 0, 0); // Show 0 on error
      },
    );
  }

  Widget _buildCountsDisplay(int total, int completed, int cancelled) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // total
          _buildCountContainer('전체', total),

          Container(height: 50, width: 1, color: Colors.grey.shade200),

          // complete
          _buildCountContainer('완료', completed),

          Container(height: 50, width: 1, color: Colors.grey.shade200),

          // cancel
          _buildCountContainer('취소', cancelled),
        ],
      ),
    ).pSymmetric(h: 20, v: 16).box.color(Colors.white).make();
  }

  Widget _buildCountContainer(String title, int count) {
    Color textColor = Colors.black;

    switch (title) {
      case '전체':
        textColor = Colors.black;
        break;
      case '완료':
        textColor = Colors.blue;
        break;
      case '취소':
        textColor = Colors.grey;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // title
        title.text.color(Colors.grey.shade800).size(12).make(),

        // count
        '$count회'.text.size(20).color(textColor).bold.make(),
      ],
    ).box.make();
  }

  Widget _buildMyVehicleList() {
    final currentUser = ref.watch(currentUserProvider);
    final vehicles = currentUser?.vehicles ?? [];
    final count = vehicles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // title
            Row(
              children: [
                '내 차량 '.text.size(16).bold.make(),
                count.text.size(20).color(Colors.purple).bold.make(),
              ],
            ),

            // add button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VehicleAddScreen()),
                );
              },
              child: '+ 차량 추가'.text.size(12).color(Colors.grey.shade800).make(),
            ),
          ],
        ),
        SizedBox(height: 16),

        // list or empty state
        if (vehicles.isEmpty)
          _buildEmptyVehicleState()
        else
          ...vehicles.map(
            (vehicle) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildVehicleContainer(vehicle),
            ),
          ),
      ],
    ).pSymmetric(v: 12, h: 16).box.color(Colors.white).make();
  }

  Widget _buildVehicleContainer(Vehicle vehicle) {
    // Build display text for model and color
    final modelText = vehicle.manufacturer != null && vehicle.model != null
        ? '${vehicle.manufacturer} ${vehicle.model}'
        : vehicle.manufacturer ?? vehicle.model ?? '모델 정보 없음';

    final colorText = vehicle.color ?? '색상 정보 없음';
    final detailText = '$modelText | $colorText';

    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 차량 번호
            vehicle.plateNumber.text.size(19).bold.make(),
            SizedBox(height: 8),

            // 차량 모델 | 색상
            detailText.text.size(15).color(Colors.grey.shade800).make(),
            SizedBox(height: 8),

            // 수정 & 삭제 버튼
            Row(
              children: [
                // 수정
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VehicleEditScreen()),
                    );
                  },
                  child: '수정'.text
                      .size(13)
                      .color(Colors.grey.shade800)
                      .underline
                      .make(),
                ),

                SizedBox(width: 16),

                // 삭제
                GestureDetector(
                  onTap: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('차량 삭제'),
                        content: Text('${vehicle.plateNumber} 차량을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref
                                  .read(userProvider.notifier)
                                  .removeVehicle(vehicle.plateNumber);
                            },
                            child: Text(
                              '삭제',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: '삭제'.text
                      .textStyle(
                        TextStyle(
                          fontSize: 13,
                          color: Colors.redAccent,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.redAccent,
                        ),
                      )
                      .make(),
                ),
              ],
            ),
          ],
        )
        .p(16)
        .box
        .rounded
        .color(Colors.grey.shade50)
        .border(color: Colors.grey.shade200)
        .make();
  }

  Widget _buildEmptyVehicleState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12),
          '등록된 차량이 없습니다'.text.size(16).color(Colors.grey.shade600).make(),
          SizedBox(height: 8),
          '+ 차량 추가 버튼을 눌러 차량을 등록해보세요'.text
              .size(13)
              .color(Colors.grey.shade500)
              .make(),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    IconData iconData,
    String title,
    bool isTrue, {
    required Function(bool) onChanged,
    bool isEnabled = true,
  }) {
    return Row(
      children: [
        // Icon
        Icon(
          iconData,
          size: 24,
          color: isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        SizedBox(width: 8),

        // title
        title.text
            .size(16)
            .color(isEnabled ? Colors.grey.shade800 : Colors.grey.shade400)
            .fontWeight(FontWeight.w600)
            .make(),
        Spacer(),

        // toggle
        CupertinoSwitch(value: isTrue, onChanged: isEnabled ? onChanged : null),
      ],
    ).pSymmetric(v: 4);
  }

  Widget _buildMenuItem(
    IconData iconData,
    String title, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          Icon(iconData, size: 24, color: Colors.grey.shade600),
          SizedBox(width: 8),

          // title
          title.text
              .size(16)
              .color(Colors.grey.shade800)
              .fontWeight(FontWeight.w600)
              .make(),
          Spacer(),

          // toggle
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
        ],
      ).pSymmetric(v: 8),
    );
  }

  Widget _buildAppVersion() {
    return Row(
      children: [
        // title
        '앱 버전'.text
            .size(14)
            .color(Colors.grey.shade800)
            .fontWeight(FontWeight.w500)
            .make(),
        Spacer(),

        // toggle
        '1.2.7'.text.size(15).fontWeight(FontWeight.w500).make(),
      ],
    ).pSymmetric(v: 8);
  }

  Widget _buildLogout() {
    return GestureDetector(
      onTap: () {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('로그아웃'),
            content: Text('로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog

                  try {
                    // Sign out via auth provider
                    await ref.read(authControllerProvider).signOut();

                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('로그아웃되었습니다'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    Log.e('로그아웃 실패', e);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('로그아웃에 실패했습니다'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                child: Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),

            // Text
            '로그아웃'.text.size(16).color(Colors.redAccent).make(),
          ],
        ).pSymmetric(v: 16).box.roundedSM.color(Vx.red100).make(),
      ),
    ).p(20);
  }

  Widget _buildDeleteAccountLink() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '회원 탈퇴',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('정말 탈퇴하시겠습니까?', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 12),
                Text(
                  '탈퇴 시 모든 데이터가 삭제되며\n복구할 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '취소',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Save context before async
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  navigator.pop();

                  try {
                    await ref.read(authControllerProvider).deleteAccount();
                    // 회원 탈퇴 완료 - authStateChanges가 자동으로 로그아웃 처리
                  } catch (e) {
                    Log.e('회원 탈퇴 실패', e);

                    if (mounted) {
                      // Check if error is requires-recent-login
                      if (e.toString().contains('requires-recent-login')) {
                        // 재로그인 필요
                        await ref.read(authControllerProvider).signOut();

                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              '보안을 위해 재로그인이 필요합니다.\n로그인 후 다시 시도해주세요.',
                            ),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('회원 탈퇴에 실패했습니다: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text(
                  '탈퇴',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Center(
        child: '회원 탈퇴'.text
            .size(12)
            .color(Colors.grey.shade500)
            .underline
            .make(),
      ),
    ).pSymmetric(v: 12);
  }

  void _showEditNameDialog(User user) {
    final nameController = TextEditingController(text: user.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이름 수정'),
        content: SizedBox(
          // Container 대신 SizedBox 권장
          width: MediaQuery.of(context).size.width, // 혹은 제거
          child: Column(
            mainAxisSize: MainAxisSize.min, // 콘텐츠 크기만큼만 차지하도록 설정
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              '이름'.text.size(14).color(Colors.grey.shade700).make(),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '이름을 입력하세요',
                ),
              ),
            ],
          ),
        ),
        actions: [
          // 취소 버튼
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: Colors.grey.shade600)),
          ),
          // 확인 버튼
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();

              // 입력 검증
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('이름을 입력해주세요'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // 기존 이름과 같으면 그냥 닫기
              if (newName == user.name) {
                Navigator.pop(context);
                return;
              }

              try {
                // 로딩 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('이름 변경 중...'),
                      ],
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );

                // 사용자 이름 업데이트
                await ref.read(userProvider.notifier).updateUser(name: newName);

                // 성공 메시지
                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이름이 변경되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                // 에러 메시지
                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이름 변경에 실패했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              '확인',
              style: TextStyle(color: Vx.blue600, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
