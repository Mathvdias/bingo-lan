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
  String get manualGlobe => '手動';

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
  String playersInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ルームに$count人のプレイヤー',
      zero: 'ルームにプレイヤーはいません',
    );
    return '$_temp0';
  }

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
  String get scanWifiBannerNoWifi => 'Wi-Fiに接続されていません。ホストのネットワークに接続してください。';

  @override
  String scanWifiBannerOnWifi(String ip) {
    return 'Wi-Fi接続中（$ip）。ホストと同じネットワークを使ってください。';
  }

  @override
  String get scanManualButton => 'コードを入力';

  @override
  String get revealNetwork => 'ネットワークを表示';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get aboutDeveloper => '開発者 (GitHub)';

  @override
  String aboutVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get aboutTitle => 'ビンゴについて';

  @override
  String get aboutImportantTitle => '重要：同じWi-Fiネットワーク';

  @override
  String get aboutImportantBody =>
      'ビンゴは安全なローカル接続で機能します。プレイヤーがあなたのルームを見つけるには、全員（ホストを含む）が全く同じWi-Fiネットワークに接続している必要があります。';

  @override
  String get aboutHowToPlayTitle => '遊び方 (ステップバイステップ)';

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
  String get aboutLanguage => '言語';

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
  String get inviteTitle => 'プレイヤーを招待';

  @override
  String get inviteScanDesc => 'スキャンしてルームに参加！';

  @override
  String inviteShareLinkMessage(String qrData) {
    return 'ビンゴで遊ぼう！スマホからリンクをタップするだけ:\n$qrData';
  }

  @override
  String inviteConnectedPlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人が接続中',
      zero: 'まだプレイヤーは接続していません',
    );
    return '$_temp0';
  }

  @override
  String get inviteWaitingPlayers => 'プレイヤーを待っています...';

  @override
  String get inviteStartBingo => 'ビンゴを開始！';

  @override
  String get lobbyPremiumTag => 'プレミアム';

  @override
  String get lobbyUpgradeButton => 'プレミアム';

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
  String get paywallHeroTitle => 'プレミアムになる';

  @override
  String get paywallHeroSubtitle => 'もっと大きなパーティーを、制限も広告もなしで。';

  @override
  String get paywallBenefitUnlimitedPlayers => '1ルームの参加人数が無制限';

  @override
  String get paywallBenefitAutoGlobe => '自動グローブ：アプリが自動でボールを抽選';

  @override
  String get paywallBenefitNoAds => '広告なし';

  @override
  String get paywallPeriodWeekly => '週額';

  @override
  String get paywallPeriodMonthly => '月額';

  @override
  String get paywallPeriodTwoMonth => '2か月ごと';

  @override
  String get paywallPeriodThreeMonth => '3か月ごと';

  @override
  String get paywallPeriodSixMonth => '6か月ごと';

  @override
  String get paywallPeriodAnnual => '年額';

  @override
  String get paywallPeriodLifetime => '買い切り';

  @override
  String get paywallPeriodCustom => 'プラン';

  @override
  String get paywallBilledWeekly => '毎週請求';

  @override
  String get paywallBilledMonthly => '毎月請求';

  @override
  String get paywallBilledTwoMonth => '2か月ごとに請求';

  @override
  String get paywallBilledThreeMonth => '3か月ごとに請求';

  @override
  String get paywallBilledSixMonth => '6か月ごとに請求';

  @override
  String get paywallBilledAnnual => '年に1回請求';

  @override
  String get paywallBilledCustom => 'サブスクリプション';

  @override
  String get paywallOneTimePayment => '1回限りのお支払い';

  @override
  String paywallSavings(int percent) {
    return '$percent%お得';
  }

  @override
  String paywallCta(String price) {
    return '$priceで続ける';
  }

  @override
  String get paywallRestore => '購入を復元';

  @override
  String get paywallLegal =>
      'サブスクリプションは、現在の期間終了の24時間前までに解約しない限り自動更新されます。ストアのアカウント設定からいつでも解約できます。';

  @override
  String get paywallEmpty => '現在利用できるプランはありません。';

  @override
  String get paywallRetry => '再試行';

  @override
  String get paywallErrorLoad => 'プランを読み込めませんでした。接続を確認してもう一度お試しください。';

  @override
  String get paywallErrorPurchase => '購入を完了できませんでした。もう一度お試しください。';

  @override
  String get paywallErrorRestore => '購入を復元できませんでした。もう一度お試しください。';

  @override
  String get paywallRestoreNothing => 'このアカウントに過去の購入は見つかりませんでした。';

  @override
  String get paywallRestoreSuccess => '購入を復元しました。プレミアムへようこそ！';

  @override
  String get paywallClose => '閉じる';

  @override
  String playersCapacity(int count, int max) {
    return '$count/$max人（無料プラン）';
  }

  @override
  String get routeErrorMessage => 'この画面を開けませんでした。';

  @override
  String get cardFree => 'FREE';

  @override
  String get inviteDefaultRoomName => 'ビンゴルーム';

  @override
  String get hostSetupErrorEmptyName => 'ルーム名を入力してください。';

  @override
  String get hostSetupErrorNoWifi => 'Wi-Fiのアドレスを取得できませんでした。Wi-Fi接続を確認してください。';

  @override
  String get hostSetupErrorPortUnavailable =>
      'ルームを作成できるネットワークポートがありません。ネットワークを使用している他のアプリを閉じてから、もう一度お試しください。';

  @override
  String get hostSetupErrorUnexpected => 'ルームの作成中に問題が発生しました。もう一度お試しください。';

  @override
  String get hostRoomErrorConnection => 'プレイヤーとの接続に問題が発生しました。';

  @override
  String get hostRoomWinnerTitle => 'ビンゴ！';

  @override
  String hostRoomWinnerMessage(String name) {
    return '$nameさんがこのラウンドの勝者です！';
  }

  @override
  String get hostRoomNewRound => '次のラウンド';

  @override
  String get hostRoomEndRoom => 'ルームを終了';

  @override
  String get hostRoomWaitingDraw => '最初の番号を引いてラウンドを始めましょう。';

  @override
  String get hostRoomRoundOverHint => 'ラウンド終了。次のラウンドを始めるか、ルームを終了してください。';

  @override
  String drawnCount(int count) {
    return '$count/75 個';
  }

  @override
  String get scanErrorInvalidCode => '無効なコードです。ホストに新しいQRコードをもらってください。';

  @override
  String get scanErrorRejected =>
      'ホストが接続を受け付けませんでした。Wi-Fiネットワークとルームコードを確認してください。';

  @override
  String get scanErrorTimeout => 'ホストから応答がありません。同じWi-Fiネットワークに接続しているか確認してください。';

  @override
  String get scanErrorUnexpected => 'ルームへの参加中に予期しないエラーが発生しました。';

  @override
  String get scanErrorNotOnWifi =>
      'Wi-Fiに接続されていません。ホストと同じネットワークに接続してからやり直してください。';

  @override
  String scanErrorDifferentNetwork(String playerIp, String hostIp) {
    return '別のネットワークにいるようです（あなたのIP $playerIp、ホスト $hostIp）。ホストと同じWi-Fiネットワークに接続してください。';
  }

  @override
  String get scanErrorHostUnreachable =>
      'ホストに接続できませんでした。同じWi-Fiネットワークにいるか確認してください。ゲスト用、ホテル、マンションのネットワークは端末同士の通信を遮断することが多いので、その場合はホストのテザリングを使ってください。';

  @override
  String get scanErrorRoomClosed => 'ルームはもう開いていません。ホストに新しい招待をもらってください。';

  @override
  String get playerGameLastCalled => '最新の番号';

  @override
  String get playerGameNoCallsYet => 'まだ番号は引かれていません';

  @override
  String get connectionConnecting => 'ホストに接続中...';

  @override
  String get connectionReconnecting => '接続が切れました。再接続中...';

  @override
  String get connectionDisconnected => 'ホストから切断されました。';

  @override
  String get connectionRetry => '再試行';

  @override
  String get playerGameYouWon => 'ビンゴ！あなたの勝ちです！';

  @override
  String playerGameSomeoneWon(String name) {
    return '$nameさんがこのラウンドの勝者です。';
  }

  @override
  String get playerGameWaitNextRound => 'ホストが次のラウンドを始めるのを待つか、ホームに戻ってください。';

  @override
  String get backToLobby => 'ホームに戻る';

  @override
  String get playerGameClaimRejected => 'まだビンゴではありません！カードを確認して続けましょう。';

  @override
  String get playerGameRoomClosedTitle => 'ホストがルームを終了しました';

  @override
  String get playerGameRoomClosedMessage => 'ゲームは終了しました。遊んでくれてありがとう！';

  @override
  String get playerGameLeaveTitle => 'ゲームを退出しますか？';

  @override
  String get playerGameLeaveMessage => 'カードを失い、ルームから退出します。';

  @override
  String get playerGameLeave => '退出';

  @override
  String get playerGameStay => '残る';

  @override
  String playerGameShoutCooldown(int seconds) {
    return '$seconds秒待ってください';
  }

  @override
  String get inviteShareInvite => '招待を共有';

  @override
  String get inviteCopyLink => 'リンクをコピー';

  @override
  String get inviteLinkCopied => 'リンクをコピーしました';

  @override
  String invitePasteHint(String button) {
    return 'または「$button」にリンクを貼り付けてもらいましょう';
  }

  @override
  String get playersCapacityLabel => '人（無料プラン）';

  @override
  String get playersConnectedLabel => '人が接続中';

  @override
  String get hostRoomUndoLast => '最後のボールを取り消す';

  @override
  String hostRoomUndone(String label) {
    return 'ボール $label を取り消しました';
  }

  @override
  String get hostRoomPause => '一時停止';

  @override
  String get hostRoomResume => '再開';

  @override
  String get hostRoomEmptyTitle => 'まだボールなし';

  @override
  String get tourSkip => 'スキップ';

  @override
  String get tourNext => '次へ';

  @override
  String get cardCellMarked => 'マーク済み';

  @override
  String get cardCellCalled => '抽選済み、未マーク';

  @override
  String get cardCellNotCalled => '未抽選';

  @override
  String get cardCellFreeSpace => 'フリースペース';

  @override
  String get scanCameraDeniedTitle => 'カメラにアクセスできません';

  @override
  String get scanCameraDeniedMessage =>
      'QRコードを読み取るには設定でカメラの使用を許可するか、コードを手動で入力してください。';

  @override
  String get scanCameraErrorMessage =>
      'カメラを起動できませんでした。もう一度試すか、コードを手動で入力してください。';

  @override
  String get scanOpenSettings => '設定を開く';
}
