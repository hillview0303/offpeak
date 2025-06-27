# 🌟 Offpeak
**조용하고 특별한 여행지를 찾아주는 AI 여행 컨시어지**

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AI](https://img.shields.io/badge/AI_Powered-FF6B6B?style=for-the-badge&logo=openai&logoColor=white)

**🤖 Powered by Wanted LaaS & 한국관광공사 공공데이터**

</div>

---

## ✨ 앱 소개

> *"혼잡한 여행은 그만, 나만의 조용한 여행지를 찾아보세요!"*

**Offpeak**은 AI와 실시간 데이터를 활용해 **혼잡하지 않은 여행지**를 추천하는 스마트 여행 앱입니다. 
자연어 대화를 통해 개인 맞춤형 여행 계획을 세우고, 실제 방문자 데이터로 최적의 여행 시간을 제안받을 수 있습니다.

### 🎯 핵심 가치
- **🧘 평화로운 여행**: 붐비지 않는 숨겨진 명소 발견
- **🤖 AI 맞춤 추천**: 자연어 대화로 완벽한 여행지 매칭  
- **📊 데이터 기반**: 실시간 혼잡도와 방문자 통계 제공
- **🎨 직관적 경험**: 아름답고 사용하기 쉬운 인터페이스

---

## 🚀 주요 기능

### 💬 **AI 챗봇 여행 컨시어지**
```
"부산 산책로 추천해줘"
"12월에 경주 여행 어때? 날씨는 괜찮을까?"
"지금 해운대 혼잡도는 어떻게 돼?"
"경복궁에 대해 알려줘"
```
자연스러운 대화로 맞춤형 여행지를 추천받으세요.

### 🎯 **교통수단별 맞춤 추천**
- **🚶‍♀️ 도보**: 산책하기 좋은 공원과 거리
- **🚇 대중교통**: 지하철·버스로 편리하게 갈 수 있는 명소  
- **🚗 드라이브**: 경치 좋은 드라이브 코스와 전망대
- **🚴‍♀️ 자전거**: 자전거 전용도로와 라이딩 코스

### 📊 **실시간 혼잡도 정보**
- 지난주 vs 이번주 방문자 수 비교
- 최적 방문 시간 추천
- 피크 시간대 알림
- 관광공사 공식 데이터 기반

### 🗺️ **스마트 지역 필터**
- 전국 17개 시도 선택 가능
- 실제 관광공사 지역코드 연동
- 지역별 특화 정보 제공

### 📱 **사용자 친화적 인터페이스**
- 아름다운 카드 기반 디자인
- 드래그 가능한 상세 정보 시트
- 즐겨찾기 및 하트 기능
- 지도 앱 연동 (구글맵, 카카오맵, 네이버맵)

---

## 🛠️ 기술 스택

### **Frontend**
- **Flutter** - 크로스플랫폼 앱 개발
- **Dart** - 메인 프로그래밍 언어
- **Hooks Riverpod** - 상태 관리 및 의존성 주입

### **APIs**
- **Wanted LaaS** - AI 프롬프트 API
- **한국관광공사 TourAPI** - 관광지 정보 및 방문자 통계 및 혼잡도

### **주요 라이브러리**
- `http` - API 통신
- `url_launcher` - 외부 앱 연동
- `flutter_dotenv` - 환경변수 관리
- `intl` - 국제화 및 날짜 포맷

---

## 📱 스크린샷

<div style="text-align: center; width: 100%;">
  <div style="display: inline-block; width: 22%; text-align: center;">메인 화면</div>
  <div style="display: inline-block; width: 22%; text-align: center;">AI 챗봇</div>
  <div style="display: inline-block; width: 22%; text-align: center;">교통편별 추천</div>
  <div style="display: inline-block; width: 22%; text-align: center;">상세 정보</div>
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/fa20c5d3-1acd-4bba-aa18-50fabd9e13fc" width="22%" />
  <img src="https://github.com/user-attachments/assets/db39f6f1-217c-4d4a-96b4-5393df08fa0b" width="22%" />
  <img src="https://github.com/user-attachments/assets/32419bd8-4514-48c7-af21-7699380dd0b0" width="22%" />
  <img src="https://github.com/user-attachments/assets/3e8a2523-1ac4-4dab-9d25-588dc9267c40" width="22%" />
</div>


---

## ⚙️ 설치 및 실행

### 📋 **필수 요구사항**
- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Android Studio / VS Code
- Android/iOS 시뮬레이터 또는 실제 기기

### 🔧 **설치 과정**

1. **레포지토리 클론**
```bash
git clone https://github.com/your-username/offpeak.git
cd offpeak
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경변수 설정**
```bash
# .env 파일 생성
cp .env.example .env
```

`.env` 파일에 다음 값들을 설정하세요:
```env
# Wanted LaaS API
LAAS_API_URL=your_laas_api_url
LAAS_API_KEY=your_laas_api_key
LAAS_HASH=your_laas_hash
LAAS_PROJECT_ID=your_laas_project_id

# 한국관광공사 API
TOUR_API_SERVICE_KEY=your_tour_api_service_key
```

4. **앱 실행**
```bash
flutter run
```

### 🔑 **API 키 발급**
- **Wanted LaaS**: [Wanted LaaS 콘솔](https://laas.wanted.co.kr)에서 발급
- **한국관광공사**: [Tour API](https://www.data.go.kr/data/15101578/openapi.do)에서 신청

---

## 📁 프로젝트 구조

```
lib/
├── core/                          # 핵심 공통 기능
│   ├── constants/                # 색상, 크기, 스타일 상수
│   ├── widgets/                  # 공통 위젯 (헤더, 바텀시트 등)
│   ├── router/                   # 라우팅 관리
│   └── service/                  # 외부 API 서비스
│       ├── ai_recommendation_service.dart                  # 맞춤 추천 
│       ├── nearby_service.dart                             # 내 주변
│       ├── quiet_activities_service.dart                   # 조용한 활동 추천 
│       ├── tourism_api_service.dart                        # TourAPI 연결 서비스
│       ├── transportation_travel_service.dart              # 이동 수단별 추천   
│       └── unified_laas_api_service.dart                   # Wanted Laas 연결 서비스 
├── features/                     # 기능별 모듈 (Clean Architecture)
│   ├── chat/                    # AI 챗봇
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   ├── home/                    # 메인 화면 및 추천
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       ├── providers/
│   │       └── widgets/
│   ├── main/                    # 메인 네비게이션
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   └── my/                      # 마이페이지/설정
│       └── presentation/
│           ├── pages/
│           ├── providers/
│           └── widgets/
└── main.dart                    # 앱 진입점
```

---

## 🔮 향후 개발 계획

### **Phase 2**
- [ ] 🗺️ 지도 기반 인터랙티브 추천
- [ ] 📝 여행 일정 플래너

### **Phase 3**  
- [ ] 👥 사용자 리뷰 및 평점 시스템
- [ ] 📚 개인화된 여행 다이어리
- [ ] 🔄 소셜 공유 기능
- [ ] 🏆 gamification 요소

### **Phase 4**
- [ ] 🤝 다른 여행 앱과의 연동
- [ ] 🎯 머신러닝 기반 추천 고도화
- [ ] 🌍 해외 여행지 확장
- [ ] 💳 여행 상품 예약 기능

---

## 🎬 시연 영상

<div align="center">

[![Offpeak 데모](https://img.youtube.com/vi/YOUR_VIDEO_ID/0.jpg)](https://youtu.be/YOUR_VIDEO_ID)

**📺 [전체 시연 영상 보기](https://youtu.be/YOUR_VIDEO_ID)**

</div>

---

## 📄 라이선스

```
MIT License

Copyright (c) 2025 Offpeak Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">

### 🌟 **Offpeak과 함께 조용하고 특별한 여행을 떠나보세요!**

**Made with ❤️ by Offpeak Team**

</div>
