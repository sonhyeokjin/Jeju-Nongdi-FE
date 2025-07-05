// Redux Store 설정
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user/user_reducer.dart';

// Root Reducer - 앱 전체 상태 관리
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    userState: userStateReducer(state.userState, action),
    // 향후 추가될 다른 상태들
    // farmState: farmStateReducer(state.farmState, action),
    // chatState: chatStateReducer(state.chatState, action),
    // notificationState: notificationStateReducer(state.notificationState, action),
  );
}

// Redux Store 생성 함수
Store<AppState> createStore() {
  // 미들웨어 설정
  final List<Middleware<AppState>> middleware = [];
  
  // 개발 모드에서 Redux 액션 로깅 활성화
  const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;
  if (kDebugMode) {
    middleware.add(LoggingMiddleware.printer());
  }
  
  // 추가 미들웨어들을 여기에 추가할 수 있습니다
  // middleware.add(apiMiddleware);
  // middleware.add(storageMiddleware);
  // middleware.add(thunkMiddleware);
  
  final store = Store<AppState>(
    appReducer,                    // 단순한 root reducer 함수
    initialState: AppState.initial(),
    middleware: middleware,
  );
  
  return store;
}

// Store 인스턴스 (싱글톤 패턴)
late final Store<AppState> store;

// Store 초기화 함수
void initializeStore() {
  store = createStore();
}

// 편의 함수들
class StoreProvider {
  static Store<AppState> get instance => store;
  
  // 현재 상태 조회
  static AppState get state => store.state;
  
  // 사용자 상태 조회 편의 메서드들
  static bool get isAuthenticated => store.state.userState.isAuthenticated;
  static bool get isLoading => store.state.userState.isLoading;
  static String? get accessToken => store.state.userState.accessToken;
  static String? get errorMessage => store.state.userState.errorMessage;
  
  // 액션 디스패치
  static void dispatch(dynamic action) {
    store.dispatch(action);
  }
}

// 스토어 상태 변화를 구독하는 편의 함수들
typedef StateChangeCallback = void Function(AppState state);

class StoreSubscription {
  static void subscribe(StateChangeCallback callback) {
    store.onChange.listen(callback);
  }
  
  // 사용자 상태 변화만 구독
  static void subscribeToUserState(void Function() callback) {
    store.onChange
        .map((state) => state.userState)
        .distinct()
        .listen((_) => callback());
  }
  
  // 인증 상태 변화만 구독
  static void subscribeToAuthState(void Function(bool isAuthenticated) callback) {
    store.onChange
        .map((state) => state.userState.isAuthenticated)
        .distinct()
        .listen(callback);
  }
}
