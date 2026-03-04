import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Firebase Admin 초기화
admin.initializeApp();

/**
 * 예약 상태별 알림 메시지 템플릿
 */
interface NotificationMessage {
  title: string;
  body: string;
}

/**
 * 예약 상태에 따른 알림 메시지 생성
 * @param {string} beforeStatus - 변경 전 상태
 * @param {string} afterStatus - 변경 후 상태
 * @param {string} parkingLotName - 주차장 이름
 * @param {object} beforeData - 변경 전 예약 데이터
 * @param {object} afterData - 변경 후 예약 데이터
 * @return {NotificationMessage} 알림 메시지 객체
 */
function getNotificationMessage(
  beforeStatus: string,
  afterStatus: string,
  parkingLotName: string,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  beforeData: any,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  afterData: any
): NotificationMessage | null {
  // 특정 상태 전환에 대한 커스텀 메시지
  const transitionKey = `${beforeStatus}_to_${afterStatus}`;

  // exitRequested -> confirmed 전환일 때 expectedExit에 따라 다른 메시지
  if (transitionKey === "exitRequested_to_confirmed") {
    const beforeExit = beforeData.expectedExit;
    const afterExit = afterData.expectedExit;

    // null, undefined 체크를 위한 명확한 boolean 변환
    const hadExit = beforeExit != null;
    const hasExit = afterExit != null;

    functions.logger.info(
      `exitRequested->confirmed: had=${hadExit}, has=${hasExit}`
    );

    // before와 after의 expectedExit을 비교
    // before에 있었는데 after에 null이면 거절
    // before에 없었는데 after에 있으면 승인
    if (hadExit && !hasExit) {
      // 거절: 기존에 있던 expectedExit이 제거됨
      functions.logger.info("출차 요청 거절 알림 발송");
      return {
        title: "출차 요청이 거절되었습니다",
        body: `${parkingLotName} 출차 요청이 거절되었습니다. 사장님께 문의해주세요.`,
      };
    } else if (!hadExit && hasExit) {
      // 승인: 새로 expectedExit이 추가됨
      functions.logger.info("출차 요청 승인 알림 발송");
      return {
        title: "출차 요청이 승인되었습니다",
        body: `${parkingLotName} 출차 시간에 맞게 도착해주세요.`,
      };
    } else {
      // 예상치 못한 경우
      functions.logger.warn(`Unexpected: had=${hadExit}, has=${hasExit}`);
      return null;
    }
  }

  const transitionMessages: { [key: string]: NotificationMessage | null } = {};

  // 전환 메시지가 있으면 우선 반환
  if (transitionMessages[transitionKey] !== undefined) {
    return transitionMessages[transitionKey];
  }

  // 일반 상태별 메시지
  const messages: { [key: string]: NotificationMessage | null } = {
    approved: {
      title: "예약이 승인되었습니다",
      body: `${parkingLotName} 예약이 승인되었습니다. 예약시간에 맞게 도착해주세요.`,
    },
    confirmed: {
      title: "입차가 완료되었습니다",
      body: `${parkingLotName} 차량이 안전하게 관리중입니다.`,
    },
    exitRequested: {
      title: "출차 요청이 접수되었습니다",
      body: `${parkingLotName} 출차 요청이 접수되었습니다. 사장님께서 확인 후 알려드립니다.`,
    },
    completed: {
      title: "출차가 완료되었습니다",
      body: `${parkingLotName} 출차가 완료되었습니다. 이용해 주셔서 감사합니다.`,
    },
    cancelled: {
      title: "예약이 취소되었습니다",
      body: `${parkingLotName} 예약이 취소되었습니다.`,
    },
  };

  return messages[afterStatus] || {
    title: "예약 상태가 변경되었습니다",
    body: `${parkingLotName} 예약 상태가 ${afterStatus}로 변경되었습니다.`,
  };
}

/**
 * 예약 상태 변경 시 자동으로 푸시 알림 전송
 */
export const onReservationStatusChange = functions.firestore
  .document("reservations/{reservationId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const reservationId = context.params.reservationId;

    // 상태가 변경되지 않았으면 종료
    if (before.status === after.status) {
      functions.logger.info(
        `Reservation ${reservationId}: 상태 변경 없음`
      );
      return null;
    }

    functions.logger.info(
      `Reservation ${reservationId}: ${before.status} -> ${after.status}`
    );

    try {
      // visitorId로 사용자 FCM 토큰 조회
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(after.visitorId)
        .get();

      if (!userDoc.exists) {
        functions.logger.warn(
          `User ${after.visitorId} not found`
        );
        return null;
      }

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        functions.logger.warn(
          `User ${after.visitorId} has no FCM token`
        );
        return null;
      }

      // 상태별 메시지 작성
      const message = getNotificationMessage(
        before.status,
        after.status,
        after.parkingLotName || "주차장",
        before,
        after
      );

      // 메시지가 null이면 알림 발송하지 않음 (exitRequested 등)
      if (message === null) {
        functions.logger.info(
          `Reservation ${reservationId}: ${after.status} 상태는 알림 발송 안 함`
        );
        return null;
      }

      // FCM 전송
      const response = await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: message.title,
          body: message.body,
        },
        data: {
          type: "reservation_status_change",
          reservationId: reservationId,
          status: after.status,
          parkingLotName: after.parkingLotName || "",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "reservation_updates",
            priority: "max",
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          headers: {
            "apns-priority": "10",
          },
          payload: {
            aps: {
              "alert": {
                title: message.title,
                body: message.body,
              },
              "sound": "default",
              "badge": 1,
              "content-available": 1,
            },
          },
        },
      });

      functions.logger.info(
        `FCM sent successfully to ${after.visitorId}: ${response}`
      );
      return response;
    } catch (error) {
      functions.logger.error(
        `Failed to send FCM for reservation ${reservationId}:`,
        error
      );
      return null;
    }
  });
