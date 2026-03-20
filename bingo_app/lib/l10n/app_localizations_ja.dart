// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Bingo Lucca';

  @override
  String get startBingo => 'ビンゴを開催する';

  @override
  String get joinBingo => 'ビンゴに参加する';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get premiumBadge => 'プレミアム';

  @override
  String get manualGlobe => '手動 (物理)';

  @override
  String get virtualGlobe => 'バーチャル';

  @override
  String get autoGlobe => '自動グローブ (プレミアム)';

  @override
  String get drawRandom => '抽選 (ランダム)';

  @override
  String get confirm => '確認';

  @override
  String get numberInput => '番号';

  @override
  String get typeNumberHint => '抽選された番号を入力';

  @override
  String get errorInvalidNumber => '番号は1から75の間でなければなりません';

  @override
  String get errorNumberDrawn => 'この番号は既に抽選されました！';

  @override
  String get paywallTitle => '有料機能';

  @override
  String get paywallMessage => '自動グローブは有料機能です。アップグレードしてください！';

  @override
  String get stopRoomTitle => 'ルームを閉じる';

  @override
  String get stopRoomMessage => 'ルームを閉じてもよろしいですか？すべてのプレイヤーが切断されます。';

  @override
  String get no => 'いいえ';

  @override
  String get yes => 'はい';

  @override
  String get hostRoomTitle => 'ビンゴルーム (ホスト)';

  @override
  String get playersInRoom => '人のプレイヤー';

  @override
  String get shoutedBingo => 'がビンゴと叫びました！';

  @override
  String get cardId => 'カードID:';

  @override
  String get manualInputInstruction => '物理的なグローブで引かれた番号を入力してください';

  @override
  String get lobbySubtitle => 'あなたのパーティー、あなたのルール';

  @override
  String get lobbyWifiShowcase =>
      'ビンゴはローカルでのみ動作します！ゲストと同じWi-Fiネットワークに接続していることを確認してください。';

  @override
  String get lobbyWifiBannerDefault => 'ホストのWi-Fiネットワークでプレイしましょう！';

  @override
  String lobbyWifiBannerConnected(String wifiName) {
    return '現在のネットワーク：$wifiName\nホストのネットワークでプレイしましょう！';
  }

  @override
  String get buttonWifi => 'Wi-Fi';

  @override
  String get lobbyHostShowcase => 'あなたがホストでビンゴの球を引きたい場合はここをクリックしてください。';

  @override
  String get lobbyJoinShowcase => 'QRコードをスキャンして電話のカードでプレイする場合はここをクリックしてください。';

  @override
  String get lobbySoloShowcase => 'オフラインで一人でプレイを試したいですか？このモードを使用してください！';

  @override
  String get soloButton => 'ソロビンゴ';

  @override
  String get buttonConfig => '設定';

  @override
  String get scanWifiBannerDefault => 'ホストのWi-Fiネットワークに接続します。';

  @override
  String scanWifiBannerConnected(String wifiName) {
    return 'ネットワーク：$wifiName\nホストのネットワークに接続します。';
  }

  @override
  String get scanManualButton => '手動でコードを入力';

  @override
  String get revealNetwork => 'ネットワークを表示';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get aboutDeveloper => '開発者 (GitHub)';

  @override
  String get aboutTitle => 'ビンゴについて';

  @override
  String get aboutImportantTitle => '⚠️ 重要：同じWi-Fiネットワーク';

  @override
  String get aboutImportantBody =>
      'ビンゴは安全なローカル接続で機能します。プレイヤーがあなたのルームを見つけるには、全員（ホストを含む）が全く同じWi-Fiネットワークに接続している必要があります。';

  @override
  String get aboutHowToPlayTitle => '📖 遊び方 (ステップバイステップ)';

  @override
  String get aboutStep1Title => 'ホストを選ぶ';

  @override
  String get aboutStep1Desc => '一人が「ビンゴを主催」をクリックしてゲームを開始し、ルームコードを共有します。';

  @override
  String get aboutStep2Title => 'ルームのプレイヤー';

  @override
  String get aboutStep2Desc => '他の参加者は「参加」をクリックし、コードを入力します（またはカメラをQRコードに向けます）。';

  @override
  String get aboutStep3Title => 'カードのマーク';

  @override
  String get aboutStep3Desc => 'ホストが球を引きます。電話のカードの番号をタップしてマークします。';

  @override
  String get aboutStep4Title => 'ビンゴ！';

  @override
  String get aboutStep4Desc => 'カードが完成しましたか？誰よりも早く「ビンゴと叫ぶ」ボタンを押して勝ちましょう！';

  @override
  String get aboutLanguage => '🌐 言語';

  @override
  String get scanEnterName => '名前を入力';

  @override
  String get scanJoin => '参加';

  @override
  String get scanManualTitle => '手動で入力';

  @override
  String get scanManualHint => '下にコードまたはルームリンクを貼り付けてください：';

  @override
  String get scanCancel => 'キャンセル';

  @override
  String get scanShowcaseScanner => 'ホストのQRコードにカメラを向けて、すぐにルームに参加します。';

  @override
  String get inviteRoomCode => 'ルームコード';

  @override
  String get inviteShareLink => '招待リンクを共有';

  @override
  String get inviteTitle => 'プレイヤーを招待';

  @override
  String get inviteScanDesc => 'スキャンしてルームに参加！';

  @override
  String inviteShareCodeMessage(String qrData) {
    return 'ビンゴをしよう！ルームコードは：$qrData';
  }

  @override
  String get inviteShareCodeTooltip => 'コードを共有';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'ビンゴをしに来て！ここをクリック：bingo://room/$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    return '接続中のプレイヤー：$count';
  }

  @override
  String get inviteWaitingPlayers => 'プレイヤーを待っています...';

  @override
  String get inviteStartBingo => 'ビンゴを開始！';

  @override
  String get lobbyPremiumTag => 'プレミアム';

  @override
  String get lobbyUpgradeButton => 'アップグレード';

  @override
  String get playerGameTitle => 'あなたのカード';

  @override
  String get playerGameShout => 'ビンゴと叫ぶ！';

  @override
  String get playerScanNameHint => '例：マテウス';

  @override
  String get playerScanTitle => 'ビンゴに参加する';

  @override
  String get soloGameTitle => 'ソロビンゴ';

  @override
  String get soloGameDraw => '番号を引く';

  @override
  String get hostSetupTitle => 'ビンゴを主催する';

  @override
  String get hostSetupRoomHint => '例：ジョーおじさんのビンゴ';

  @override
  String get hostSetupCreate => 'ルームを作成';

  @override
  String get hostSetupNameLabel => 'ルームに名前を付ける';

  @override
  String get hostSetupWifiWarning =>
      '警告：すべてのプレーヤーは、ルームに参加するには同じWi-Fiネットワークに接続されている必要があります。';

  @override
  String get hostSetupWifiDesc => '同じWi-Fiネットワーク上の人々と遊ぶ。パーティーや集まりに最適です。';

  @override
  String get playerScanCameraHint => 'ホストのQRコードにカメラを向けてください';

  @override
  String get splashSubtitle => '最も楽しい遊び方！';
}
