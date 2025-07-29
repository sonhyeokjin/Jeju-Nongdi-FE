import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jejunongdi/redux/app_state.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_actions.dart';
import 'package:jejunongdi/redux/user_preference/user_preference_state.dart';
import 'package:jejunongdi/core/models/user_preference_models.dart';

class UserPreferenceAdvancedScreen extends StatefulWidget {
  const UserPreferenceAdvancedScreen({super.key});

  @override
  State<UserPreferenceAdvancedScreen> createState() => _UserPreferenceAdvancedScreenState();
}

class _UserPreferenceAdvancedScreenState extends State<UserPreferenceAdvancedScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLocation = '제주시';
  String _selectedCrop = '감귤';
  String _selectedNotificationType = 'WEATHER';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(LoadFarmingTypesAction());
      store.dispatch(LoadUsersByLocationAction(_selectedLocation));
      store.dispatch(LoadUsersByCropAction(_selectedCrop));
      store.dispatch(LoadUsersByNotificationTypeAction(_selectedNotificationType));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '고급 설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF2711C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF2711C),
          tabs: const [
            Tab(text: '농업 유형'),
            Tab(text: '지역별'),
            Tab(text: '작물별'),
            Tab(text: '알림별'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: StoreConnector<AppState, UserPreferenceState>(
        converter: (store) => store.state.userPreferenceState,
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildFarmingTypesTab(state),
              _buildLocationTab(state),
              _buildCropTab(state),
              _buildNotificationTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFarmingTypesTab(UserPreferenceState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '농업 유형 목록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      StoreProvider.of<AppState>(context).dispatch(LoadFarmingTypesAction());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2711C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('농업 유형 새로고침'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.farmingTypes.isNotEmpty
                ? ListView.builder(
                    itemCount: state.farmingTypes.length,
                    itemBuilder: (context, index) {
                      final farmingType = state.farmingTypes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFF2711C),
                            child: Icon(Icons.agriculture, color: Colors.white),
                          ),
                          title: Text(farmingType.name),
                          subtitle: Text(farmingType.description),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      '농업 유형 데이터를 불러오는 중...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab(UserPreferenceState state) {
    final locations = ['제주시', '서귀포시', '애월읍', '한림읍', '한경면', '대정읍', '안덕면', '남원읍', '표선면', '성산읍', '구좌읍', '조천읍'];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '지역별 사용자 조회',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    items: locations.map((location) => 
                      DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLocation = value;
                        });
                        StoreProvider.of<AppState>(context).dispatch(
                          LoadUsersByLocationAction(value),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '지역 선택',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.usersByLocation.isNotEmpty
                ? ListView.builder(
                    itemCount: state.usersByLocation.length,
                    itemBuilder: (context, index) {
                      final user = state.usersByLocation[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFF2711C).withOpacity(0.1),
                            child: const Icon(Icons.person, color: Color(0xFFF2711C)),
                          ),
                          title: Text('사용자 ${user.userId}'),
                          subtitle: Text('${user.farmLocation} • ${user.farmingType}'),
                          onTap: () => _showUserPreferenceDialog(context, user),
                          trailing: Text(
                            user.primaryCrops?.join(', ') ?? '관심작물 없음',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: state.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2711C)),
                          )
                        : Text(
                            '$_selectedLocation 지역에 사용자가 없습니다.',
                            style: const TextStyle(color: Colors.grey),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropTab(UserPreferenceState state) {
    final crops = ['감귤', '당근', '무', '배추', '브로콜리', '양파', '감자', '고구마', '토마토', '오이'];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '작물별 사용자 조회',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCrop,
                    items: crops.map((crop) => 
                      DropdownMenuItem(
                        value: crop,
                        child: Text(crop),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCrop = value;
                        });
                        StoreProvider.of<AppState>(context).dispatch(
                          LoadUsersByCropAction(value),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '작물 선택',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.usersByCrop.isNotEmpty
                ? ListView.builder(
                    itemCount: state.usersByCrop.length,
                    itemBuilder: (context, index) {
                      final user = state.usersByCrop[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            child: const Icon(Icons.eco, color: Colors.green),
                          ),
                          title: Text('사용자 ${user.userId}'),
                          subtitle: Text('${user.farmLocation} • ${user.farmingExperience ?? 0}년 경험'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.farmSize != null ? '${user.farmSize}㎡' : '규모미상',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: state.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2711C)),
                          )
                        : Text(
                            '$_selectedCrop 작물에 관심있는 사용자가 없습니다.',
                            style: const TextStyle(color: Colors.grey),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTab(UserPreferenceState state) {
    final notificationTypes = [
      {'value': 'WEATHER', 'name': '날씨 알림'},
      {'value': 'PEST', 'name': '병해충 알림'},
      {'value': 'MARKET', 'name': '시장 알림'},
      {'value': 'LABOR', 'name': '일자리 알림'},
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '알림 유형별 사용자 조회',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedNotificationType,
                    items: notificationTypes.map((type) => 
                      DropdownMenuItem(
                        value: type['value'],
                        child: Text(type['name']!),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedNotificationType = value;
                        });
                        StoreProvider.of<AppState>(context).dispatch(
                          LoadUsersByNotificationTypeAction(value),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '알림 유형 선택',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.usersByNotificationType.isNotEmpty
                ? ListView.builder(
                    itemCount: state.usersByNotificationType.length,
                    itemBuilder: (context, index) {
                      final user = state.usersByNotificationType[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(Icons.notifications, color: Colors.blue),
                          ),
                          title: Text('사용자 ${user.userId}'),
                          subtitle: Text('${user.farmLocation} • ${user.farmingType}'),
                          onTap: () => _showUserPreferenceDialog(context, user),
                          trailing: Icon(
                            _hasAnyNotificationEnabled(user)
                                ? Icons.notifications_active 
                                : Icons.notifications_off,
                            color: _hasAnyNotificationEnabled(user)
                                ? Colors.green 
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: state.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2711C)),
                          )
                        : Text(
                            '${_getNotificationTypeName(_selectedNotificationType)} 알림을 사용하는 사용자가 없습니다.',
                            style: const TextStyle(color: Colors.grey),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getNotificationTypeName(String type) {
    switch (type) {
      case 'WEATHER': return '날씨';
      case 'PEST': return '병해충';
      case 'MARKET': return '시장';
      case 'LABOR': return '일자리';
      default: return '알림';
    }
  }

  bool _hasAnyNotificationEnabled(UserPreferenceDto user) {
    return (user.notificationWeather ?? false) ||
           (user.notificationPest ?? false) ||
           (user.notificationMarket ?? false) ||
           (user.notificationLabor ?? false);
  }

  void _showUserPreferenceDialog(BuildContext context, UserPreferenceDto user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('사용자 ${user.userId} 설정 관리'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('농장 위치', user.farmLocation ?? '미설정'),
            _buildInfoRow('농업 유형', user.farmingType ?? '미설정'),
            _buildInfoRow('농장 크기', user.farmSize != null ? '${user.farmSize}㎡' : '미설정'),
            _buildInfoRow('농업 경험', user.farmingExperience != null ? '${user.farmingExperience}년' : '미설정'),
            _buildInfoRow('주요 작물', user.primaryCrops?.join(', ') ?? '미설정'),
            _buildInfoRow('선호 시간', _getTipTimeText(user.preferredTipTime)),
            const SizedBox(height: 16),
            const Text(
              '알림 설정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNotificationStatus('날씨', user.notificationWeather ?? false),
            _buildNotificationStatus('병해충', user.notificationPest ?? false),
            _buildNotificationStatus('시장', user.notificationMarket ?? false),
            _buildNotificationStatus('일손', user.notificationLabor ?? false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          if (user.userId != null) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _createDefaultForUser(user.userId!);
              },
              child: const Text('기본설정 생성'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteUserPreference(user.userId!);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('설정 삭제'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStatus(String type, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$type 알림'),
        ],
      ),
    );
  }

  String _getTipTimeText(String? tipTime) {
    switch (tipTime) {
      case 'MORNING': return '오전 (9시)';
      case 'AFTERNOON': return '오후 (3시)';
      case 'EVENING': return '저녁 (6시)';
      default: return '미설정';
    }
  }

  void _createDefaultForUser(int userId) {
    StoreProvider.of<AppState>(context).dispatch(CreateDefaultPreferenceAction(userId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('사용자 $userId의 기본 설정을 생성했습니다.'),
        backgroundColor: const Color(0xFFF2711C),
      ),
    );
  }

  void _deleteUserPreference(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 삭제 확인'),
        content: Text('사용자 $userId의 설정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              StoreProvider.of<AppState>(context).dispatch(DeletePreferenceAction(userId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('사용자 $userId의 설정을 삭제했습니다.'),
                  backgroundColor: Colors.red.shade400,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}