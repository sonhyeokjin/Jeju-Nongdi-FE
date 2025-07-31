import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jejunongdi/core/models/ai_tip_model.dart';
import 'package:jejunongdi/core/services/ai_tips_service.dart';

// 메시지 데이터 모델
class _ChatMessage {
  final String? text;
  final bool isUser;
  final Widget? content;

  _ChatMessage({
    this.text,
    required this.isUser,
    this.content,
  });
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiTipsService _aiTipsService = AiTipsService.instance;

  final List<_ChatMessage> _messages = [];
  bool _isProcessing = false;

  // 추천 질문 목록 및 연결될 함수
  late final List<Map<String, dynamic>> _suggestionChips;

  @override
  void initState() {
    super.initState();
    _suggestionChips = [
      {'label': '오늘의 농살', 'action': _fetchTodayFarmLife, 'isPrimary': true},
      {'label': '날씨 기반 조언', 'action': _showTemporaryWeatherWarning, 'isPrimary': true, 'isDark': true},
      {'label': '작물 가격', 'action': _showPriceAndRecommendation, 'isPrimary': false},
      {'label': '작물 생육 가이드', 'action': _fetchCropGuide, 'isPrimary': false},
      {'label': '병해충 조기 경보', 'action': _fetchPestAlerts, 'isPrimary': false},
    ];
  }

  // 사용자 메시지 전송 및 AI 응답 처리 (일반 텍스트)
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _addUserMessage(text);
    // TODO: 일반 텍스트 질문에 대한 AI 응답 로직 구현 필요
    _addBotMessage(text: '"$text"에 대한 답변을 준비 중입니다.');
    _textController.clear();
  }

  // 추천 질문 버튼 처리
  Future<void> _handleChipAction(String label, Function action) async {
    _addUserMessage(label);
    if (action == _showComingSoonMessage || action == _showTemporaryWeatherWarning || action == _showPriceAndRecommendation) {
      action();
    } else {
      _addBotMessage(content: _buildLoadingIndicator());
      await action();
    }
    _scrollToBottom();
  }

  // 임시 폭염 경보 메시지 표시
  void _showTemporaryWeatherWarning() {
    const String warningText = '🔥1일부터 5일간 연속 폭염 예상!\n'
        '최고기온 35°C 이상이 5일간 지속됩니다.\n'
        '* 🌡️ 차광막 및 그늘막 설치 점검\n'
        '* 💧 자동 급수 시설 정상 작동 확인\n'
        '* ⏰ 작업 시간을 오전 7시 이전, 오후 6시 이후로 조정\n'
        '* 🧴 작업자 수분 보충용품 준비\n'
        '* 🏠 실내 작업 위주로 계획 변경';
    _addBotMessage(text: warningText);
  }

  // 임시 가격 및 추천 정보 메시지 표시
  void _showPriceAndRecommendation() {
    const String priceInfo = '🍊감귤 가격정보\n'
        '현재가: 28,000원/10kg (도매)\n'
        '전년 대비: ↗️ +15.3% 상승';
    _addBotMessage(text: priceInfo);

    Future.delayed(const Duration(milliseconds: 500), () {
      const String recommendation = '❗️작물 가격 기반 다음 작물을 추천드려요!\n'
          '추천 작물: 🥕당근\n'
          '작년 대비 29.7% 가격 상승!\n'
          '지금 파종하면 높은 수익 기대됩니다.';
      _addBotMessage(text: recommendation);
    });
  }

  // 기능 준비 중 메시지 표시
  void _showComingSoonMessage() {
    _addBotMessage(text: '해당 기능은 현재 준비 중입니다. 조금만 기다려주세요!');
  }

  // 각 기능별 데이터 로드 및 UI 업데이트 함수
  Future<void> _fetchTodayFarmLife() async {
    final result = await _aiTipsService.getTodayFarmLife();
    _removeLoadingMessage();
    if (result.isSuccess && result.data != null) {
      _addBotMessage(content: _buildTodayFarmLifeCard(result.data!));
    } else {
      _addBotMessage(text: '오늘의 농살 정보를 불러오는 데 실패했습니다.');
    }
  }

  Future<void> _fetchDailyTips() async {
    final result = await _aiTipsService.getDailyTips();
    _removeLoadingMessage();
    if (result.isSuccess && result.data!.isNotEmpty) {
      _addBotMessage(content: _buildTipsCard('맞춤 농업 팁', result.data!));
    } else {
      _addBotMessage(text: '맞춤 농업 팁을 불러오는 데 실패했습니다.');
    }
  }

  Future<void> _fetchNotifications() async {
    final result = await _aiTipsService.getNotifications();
    _removeLoadingMessage();
    if (result.isSuccess && result.data!.isNotEmpty) {
      _addBotMessage(content: _buildTipsCard('새로운 알림', result.data!));
    } else {
      _addBotMessage(text: '새로운 알림이 없습니다.');
    }
  }

  Future<void> _fetchWeatherTip() async {
    final result = await _aiTipsService.getWeatherBasedTips();
    _removeLoadingMessage();
    if (result.isSuccess && result.data != null) {
      _addBotMessage(content: _buildWeatherTipCard(result.data!));
    } else {
      _addBotMessage(text: '날씨 기반 조언을 불러오는 데 실패했습니다.');
    }
  }

  Future<void> _fetchPestAlerts() async {
    final result = await _aiTipsService.getPestAlert(region: '제주도');
    _removeLoadingMessage();
    if (result.isSuccess && result.data!.isNotEmpty) {
      _addBotMessage(content: _buildPestAlertsCard(result.data!));
    } else {
      _addBotMessage(text: '현재 병해충 경보가 없습니다.');
    }
  }

  Future<void> _fetchCropGuide() async {
    final result = await _aiTipsService.getCropGuide('감귤');
    _removeLoadingMessage();
    if (result.isSuccess && result.data != null) {
      _addBotMessage(content: _buildCropGuideCard(result.data!));
    } else {
      _addBotMessage(text: '작물 가이드를 불러오는 데 실패했습니다.');
    }
  }

  Future<void> _generateNewTip() async {
    final result = await _aiTipsService.generateDailyTip();
    _removeLoadingMessage();
    if (result.isSuccess) {
      _addBotMessage(text: '새로운 맞춤 팁이 생성되었습니다! \'맞춤 농업 팁\' 버튼을 눌러 확인해보세요.');
    } else {
      _addBotMessage(text: '팁 생성에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // 메시지 리스트 관리 헬퍼 함수
  void _addUserMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _addBotMessage({String? text, Widget? content}) {
    setState(() {
      _messages.add(_ChatMessage(text: text, content: content, isUser: false));
    });
    _scrollToBottom();
  }

  void _removeLoadingMessage() {
    setState(() {
      _messages.removeWhere((m) => m.content is Center);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: () => setState(() => _messages.clear()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildWelcomeMessage();
                }
                final message = _messages[index - 1];
                return _buildMessageItem(message);
              },
            ),
          ),
          _buildChatInputField(),
        ],
      ),
    );
  }

  // --- UI 빌더 함수들 ---

  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.asset(
                  'lib/assets/images/ai_assistant_image.png',
                  fit: BoxFit.contain,
                  width: 48,
                  height: 48,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 농업 도우미',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '궁금한 점을 물어보거나, 아래 버튼을 눌러 주요 기능을 사용해보세요.',
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _suggestionChips.map((chip) {
            return ActionChip(
              label: Text(
                chip['label'],
                style: TextStyle(
                  color: chip['isDark'] == true ? Colors.white : (chip['isPrimary'] ? Color(0xFFF2711C) : Colors.black87),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => _handleChipAction(chip['label'], chip['action'] as Function),
              backgroundColor: chip['isDark'] == true ? Colors.black : (chip['isPrimary'] ? Color(0xFFF2711C).withOpacity(0.1) : Colors.grey[200]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: chip['isPrimary'] ? Color(0xFFF2711C).withOpacity(0.2) : Colors.grey[300]!,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMessageItem(_ChatMessage message) {
    final align = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isUser ? Color(0xFFF2711C) : Colors.grey[200];
    final textColor = message.isUser ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!message.isUser) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/images/ai_assistant_image.png',
                      fit: BoxFit.contain,
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('AI 농업 도우미', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: message.content ?? Text(
                  message.text ?? '',
                  style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -1))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24.0)),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(hintText: '궁금한 사항을 입력해 주세요', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey)),
                  onSubmitted: _sendMessage,
                  onChanged: (text) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _textController.text.trim().isNotEmpty ? const Color(0xFFF2711C) : Colors.grey[300],
              radius: 24,
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: _textController.text.trim().isNotEmpty ? () => _sendMessage(_textController.text) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFF2711C)),
      ),
    );
  }

  // --- 데이터 포맷팅 카드 위젯들 ---

  Widget _buildTodayFarmLifeCard(TodayFarmLifeModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(title: '오늘의 농살', content: data.summary),
        _buildSection(title: '날씨 알림', content: data.weatherAlert),
        _buildSection(title: '작물 관리 팁', content: data.cropTip),
        _buildSection(title: '긴급 작업', content: data.urgentTasks.join('\n')),
      ],
    );
  }

  Widget _buildTipsCard(String title, List<AiTipModel> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text('• ${tip.title}'),
        )),
      ],
    );
  }

  Widget _buildWeatherTipCard(WeatherBasedTipModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.farmName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSection(title: '날씨', content: data.weatherCondition),
        _buildSection(title: '권장사항', content: data.recommendation),
        if (data.warning.isNotEmpty) _buildSection(title: '주의사항', content: data.warning, isWarning: true),
      ],
    );
  }

  Widget _buildPestAlertsCard(List<PestAlertModel> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('병해충 경보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...alerts.map((alert) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text('• [${alert.severity}] ${alert.pestName}'),
        )),
      ],
    );
  }

  Widget _buildCropGuideCard(CropGuideModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${data.cropType} 가이드', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSection(title: '현재 단계', content: data.currentStage),
        _buildSection(title: '해야 할 일', content: data.tasks.join('\n')),
        if (data.cautions.isNotEmpty) _buildSection(title: '주의사항', content: data.cautions.join('\n'), isWarning: true),
      ],
    );
  }

  Widget _buildSection({required String title, required String content, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isWarning ? Colors.red : Colors.black)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}