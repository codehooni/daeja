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
      "[getNotificationMessage] exitRequested->confirmed: " +
      `had=${hadExit}, has=${hasExit}`
    );

    // before와 after의 expectedExit을 비교
    // before에 있었는데 after에 null이면 거절
    // before에 없었는데 after에 있으면 승인
    if (hadExit && !hasExit) {
      // 거절: 기존에 있던 expectedExit이 제거됨
      functions.logger.info("[getNotificationMessage] 출차 요청 거절 알림 발송");
      return {
        title: "출차 요청이 거절되었습니다",
        body: `${parkingLotName} 출차 요청이 거절되었습니다. 사장님께 문의해주세요.`,
      };
    } else if (!hadExit && hasExit) {
      // 승인: 새로 expectedExit이 추가됨
      functions.logger.info("[getNotificationMessage] 출차 요청 승인 알림 발송");
      return {
        title: "출차 요청이 승인되었습니다",
        body: `${parkingLotName} 출차 시간에 맞게 도착해주세요.`,
      };
    } else {
      // 예상치 못한 경우
      functions.logger.warn(
        "[getNotificationMessage] Unexpected " +
        `exitRequested->confirmed transition: had=${hadExit}, ` +
        `has=${hasExit}`
      );
      return null;
    }
  }

  // TODO: 특정 상태 전환에 대한 커스텀 메시지를
  // 더 추가할 수 있습니다.
  // const transitionMessages:
  //   { [key: string]: NotificationMessage | null } = {};
  // if (transitionMessages[transitionKey] !== undefined) {
  //   return transitionMessages[transitionKey];
  // }

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
    // ⚠️ IMPORTANT: exitRequested는 사용자가 직접 누르는 "출차 요청" 버튼이므로
    // 사용자 본인에게 알림을 보낼 필요가 없습니다.
    // 대신 daeja_admin 앱의 onReservationUpdate 함수에서
    // 관리자에게 "새 출차 요청" 알림을 보냅니다.
    // 이 값을 다시 객체로 변경하지 마세요! (작성: 2026-03-06)
    exitRequested: null,
    completed: {
      title: "출차가 완료되었습니다",
      body: `${parkingLotName} 출차가 완료되었습니다. 이용해 주셔서 감사합니다.`,
    },
    cancelled: {
      title: "예약이 취소되었습니다",
      body: `${parkingLotName} 예약이 취소되었습니다.`,
    },
  };

  const notification = messages[afterStatus] || {
    title: "예약 상태가 변경되었습니다",
    body: `${parkingLotName} 예약 상태가 ${afterStatus}로 변경되었습니다.`,
  };
  functions.logger.info(
    "[getNotificationMessage] Generated notification for " +
    `status ${afterStatus}: ${JSON.stringify(notification)}`
  );
  return notification;
}

/**
 * 예약 상태 변경 시 자동으로 푸시 알림 전송
 */
export const onReservationUpdate = functions.firestore
  .document("reservations/{reservationId}")
  .onUpdate(async (change, context) => {
    const reservationId = context.params.reservationId;
    functions.logger.info(
      "[onReservationUpdate] Processing reservation " +
      `update for ID: ${reservationId}`
    );

    const before = change.before.data();
    const after = change.after.data();

    // 상태가 변경되지 않았으면 종료
    if (before.status === after.status) {
      functions.logger.info(
        `[onReservationUpdate] Reservation ${reservationId}: ` +
        `상태 변경 없음 (${before.status})`
      );
      return null;
    }

    functions.logger.info(
      `[onReservationUpdate] Reservation ${reservationId}: ` +
      `상태 변경 감지 ${before.status} -> ${after.status}`
    );

    try {
      // visitorId로 사용자 FCM 토큰 조회
      functions.logger.info(
        "[onReservationUpdate] Fetching user data for " +
        `visitorId: ${after.visitorId}`
      );
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(after.visitorId)
        .get();

      if (!userDoc.exists) {
        functions.logger.warn(
          `[onReservationUpdate] User ${after.visitorId} not ` +
          `found for reservation ${reservationId}`
        );
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;
      const tokenStatus = fcmToken ? "Exists" : "Null/Undefined";
      functions.logger.info(
        "[onReservationUpdate] User data fetched. " +
        `FCM Token: ${tokenStatus}`
      );

      if (!fcmToken) {
        functions.logger.warn(
          `[onReservationUpdate] User ${after.visitorId} has no ` +
          `FCM token for reservation ${reservationId}`
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

      // 메시지가 null이면 알림 발송하지 않음
      if (message === null) {
        functions.logger.info(
          `[onReservationUpdate] Reservation ${reservationId}: ` +
          `${after.status} 상태는 알림 메시지가 생성되지 않아 발송 안 함`
        );
        return null;
      }

      functions.logger.info(
        "[onReservationUpdate] Generated notification message: " +
        `${JSON.stringify(message)}`
      );

      // FCM 전송 시도
      functions.logger.info(
        "[onReservationUpdate] Attempting to send FCM message for " +
        `reservation ${reservationId} to token: ${fcmToken}`
      );

      const payloadData = {
        type: "reservation_status_change",
        reservationId: reservationId,
        status: after.status,
        parkingLotName: after.parkingLotName || "",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      };

      const response = await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: message.title,
          body: message.body,
        },
        data: payloadData,
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
              "badge": 1, // badge count는 추후 로직 필요
              "content-available": 1, // 포어그라운드 수신을 위해
            },
          },
        },
      });

      functions.logger.info(
        "[onReservationUpdate] FCM sent successfully for " +
        `reservation ${reservationId}: ${response}`
      );
      return response;
    } catch (error) {
      functions.logger.error(
        `[onReservationUpdate] Error processing reservation ${reservationId}:`,
        error
      );
      return null;
    }
  });

