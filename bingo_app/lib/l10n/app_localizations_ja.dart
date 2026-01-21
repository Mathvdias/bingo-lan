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
}
