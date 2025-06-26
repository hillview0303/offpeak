# 📱 Offpeak – 조용한 여행지 추천 앱

### 🧠 Powered by Prompt API (Wanted LaaS)

---

## 📌 프로젝트 소개

**Offpeak**은 프롬프트 API와 공공데이터를 활용해 **혼잡하지 않고 조용한 여행지**를 추천해주는 Flutter 기반 앱입니다.
사용자는 챗봇 형태로 질문을 입력하고, AI가 지역별 관광지 정보와 혼잡도 예측 데이터를 분석해 맞춤형 여행지를 제안합니다.

> “12월 경주 여행 어때?”, “지금 해운대 혼잡해?”, “서울 조용한 공원 추천해줘” 같은 자연어 질문을 통해 여행 계획을 쉽게 세울 수 있어요.

---

## 🛠️ 사용 기술 스택

| 영역 | 기술 |
|------|------|
| **앱 개발** | Flutter, Dart |
| **상태 관리** | Riverpod |
| **API 연동** | 한국관광공사 TourAPI, Wanted LaaS |

---

## 🧪 주요 기능

- 🧭 **AI 챗봇 기반 여행지 추천**
- 🔎 **공공 API 기반 장소 정보, 혼잡도 제공**
- 🗓️ **사용자 질문 기반 맞춤 추천 예시**
- 📸 **대표 사진, 방문자 수 등 요약 정보 제공**
- 🧘 **'조용한 여행'을 위한 추천 최적화**

---

## 🖼️ 스크린샷

> (여기에 이미지 또는 영상 썸네일 삽입)

```md
![챗봇 예시](screenshots/chatbot_example.png)
![추천 결과 예시](screenshots/result_example.png)
```

---

## ⚙️ 실행 방법

```bash
git clone https://github.com/your-username/offpeak.git
cd offpeak
flutter pub get
flutter run
```

> `.env` 파일에 다음과 같은 값을 넣어주세요:

```env
LAAS_API_URL=...
LAAS_API_KEY=...
LAAS_HASH=...
LAAS_PROJECT_ID=...
```

---

## 📹 시연 영상

👉 [영상 보러가기](https://youtu.be/your-demo-link)

---

## 📦 향후 개발 계획

- 지도 기반 추천
- 사용자 위치 기반 실시간 혼잡도 반영
- 피드백 기반 챗봇 개선
- 즐겨찾기 및 다이어리 기능 추가

---

## 📄 라이선스

MIT License © 2025 Offpeak Team
