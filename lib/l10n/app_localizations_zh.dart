// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'MAID AI Reader';

  @override
  String get home => '主页';

  @override
  String get settings => '设置';

  @override
  String get help => '帮助';

  @override
  String get appearance => '外观';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeDesc => '在浅色和深色主题之间切换';

  @override
  String get defaultHighlightColor => '默认高亮颜色';

  @override
  String get readingPreferences => '阅读偏好';

  @override
  String get defaultZoom => '默认缩放';

  @override
  String get autoSave => '自动保存';

  @override
  String get autoSaveDesc => '自动保存阅读进度';

  @override
  String get showThumbnails => '显示缩略图';

  @override
  String get showThumbnailsDesc => '在库中显示文件缩略图';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get securityPrivacy => '安全与隐私';

  @override
  String get appLock => '应用锁';

  @override
  String get appLockDesc => '需要PIN码打开应用';

  @override
  String get biometric => '生物识别认证';

  @override
  String get biometricDesc => '使用指纹或面部识别';

  @override
  String get storage => '存储';

  @override
  String get cacheSize => '缓存大小';

  @override
  String get calculating => '计算中...';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearCacheDesc => '释放存储空间';

  @override
  String get backupRestore => '备份与恢复';

  @override
  String get backupRestoreDesc => '备份笔记和注释';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get helpShortcuts => '帮助与快捷键';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get clearCacheTitle => '清除缓存';

  @override
  String get clearCacheMessage => '这将删除所有缓存的PDF页面和缩略图。您的注释和笔记不会受到影响。';

  @override
  String get cancel => '取消';

  @override
  String get clear => '清除';

  @override
  String get close => '关闭';

  @override
  String get cacheCleared => '缓存已清除！';

  @override
  String get keyboardShortcuts => '键盘快捷键：';

  @override
  String get searchInPdf => '在PDF中搜索';

  @override
  String get highlightText => '高亮选中的文本';

  @override
  String get underlineText => '下划线选中的文本';

  @override
  String get strikeoutText => '删除线选中的文本';

  @override
  String get freeDrawing => '自由绘图模式';

  @override
  String get toggleToolbar => '切换注释工具栏';

  @override
  String get addBookmark => '添加书签';

  @override
  String get navigatePages => '导航页面';

  @override
  String get pdfFeatures => 'PDF功能：';

  @override
  String get pdfFeaturesDesc =>
      '• 多种颜色的注释\\n• AI驱动的聊天和分析\\n• 带AI摘要的智能笔记\\n• 文本翻译\\n• Google搜索集成\\n• 导出对话和笔记\\n• 带过滤器的高级搜索\\n• 书签和导航';

  @override
  String get myLibrary => '我的图书馆';

  @override
  String get recentFiles => '最近文件';

  @override
  String get favorites => '收藏夹';

  @override
  String get allDocuments => '所有文档';

  @override
  String get importPdf => '导入PDF';

  @override
  String get searchDocuments => '搜索文档...';

  @override
  String get noDocumentsYet => '尚无文档';

  @override
  String get tapPlusToImport => '点击+导入您的第一个PDF';

  @override
  String get aiChat => 'AI聊天';

  @override
  String get askQuestion => '提问...';

  @override
  String get analyzing => '分析中...';

  @override
  String get summarize => '总结';

  @override
  String get simplify => '简化';

  @override
  String get translate => '翻译';

  @override
  String get search => '搜索';

  @override
  String get fitWidth => '适合宽度';

  @override
  String get fitPage => '适合页面';

  @override
  String get actualSize => '实际大小';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get chinese => '中文';

  @override
  String get sectionAppearance => '🎨 外观';

  @override
  String get sectionReadingPreferences => '📖 阅读偏好';

  @override
  String get sectionLanguage => '🌍 语言';

  @override
  String get sectionSecurity => '🔒 安全与隐私';

  @override
  String get sectionStorage => '💾 存储';

  @override
  String get sectionAbout => 'ℹ️ 关于';

  @override
  String get zoom50 => '50%';

  @override
  String get zoom75 => '75%';

  @override
  String get zoom100 => '100%';

  @override
  String get zoom150 => '150%';

  @override
  String get zoom200 => '200%';

  @override
  String get recent => '最近';

  @override
  String get allFiles => '所有文件';

  @override
  String get openPdf => '打开PDF';

  @override
  String get opening => '打开中...';

  @override
  String get noRecentFiles => '无最近文件';

  @override
  String get noRecentFilesMsg => '打开PDF开始使用。\\n您最近查看的文件将显示在这里。';

  @override
  String get allFilesTitle => '所有文件';

  @override
  String get allFilesMsg => '文件浏览功能即将推出。';

  @override
  String get fileNotFound => '文件未找到';

  @override
  String errorPickingFile(String error) {
    return '选择文件时出错：$error';
  }

  @override
  String get annotationsMultipleColors => '多种颜色的注释';

  @override
  String get aiPoweredChat => 'AI驱动的聊天和分析';

  @override
  String get smartNotes => '带AI摘要的智能笔记';

  @override
  String get textTranslation => '文本翻译';

  @override
  String get googleSearch => 'Google搜索集成';

  @override
  String get exportConversations => '导出对话和笔记';

  @override
  String get advancedSearch => '带过滤器的高级搜索';

  @override
  String get bookmarksNavigation => '书签和导航';

  @override
  String get ctrlF => 'Ctrl + F';

  @override
  String get ctrlH => 'Ctrl + H';

  @override
  String get ctrlU => 'Ctrl + U';

  @override
  String get ctrlS => 'Ctrl + S';

  @override
  String get ctrlD => 'Ctrl + D';

  @override
  String get ctrlT => 'Ctrl + T';

  @override
  String get ctrlB => 'Ctrl + B';

  @override
  String get arrowKeys => '← →';

  @override
  String get pinSetup => 'PIN设置';

  @override
  String get enterNewPin => '输入新PIN码';

  @override
  String get confirmPin => '确认PIN码';

  @override
  String get pinMismatch => 'PIN码不匹配';

  @override
  String get pinTooShort => 'PIN码至少需要4位数字';

  @override
  String get pinSetupSuccess => 'PIN码设置成功';

  @override
  String get enterPin => '输入PIN码';

  @override
  String get wrongPin => 'PIN码错误';

  @override
  String get pinLocked => '尝试次数过多。请稍后再试。';

  @override
  String get biometricPrompt => '认证以解锁';

  @override
  String get biometricSuccess => '认证成功';

  @override
  String get biometricFailed => '认证失败';

  @override
  String get notes => '笔记';

  @override
  String get addNote => '添加笔记';

  @override
  String get editNote => '编辑笔记';

  @override
  String get deleteNote => '删除笔记';

  @override
  String get noteTitle => '笔记标题';

  @override
  String get noteContent => '笔记内容';

  @override
  String get saveNote => '保存笔记';

  @override
  String get deleteNoteConfirm => '您确定要删除此笔记吗？';

  @override
  String get delete => '删除';

  @override
  String get annotations => '注释';

  @override
  String get highlight => '高亮';

  @override
  String get underline => '下划线';

  @override
  String get strikethrough => '删除线';

  @override
  String get draw => '绘制';

  @override
  String get eraser => '橡皮擦';

  @override
  String get colorPicker => '颜色选择器';

  @override
  String get thickness => '粗细';

  @override
  String get opacity => '不透明度';

  @override
  String get page => '页';

  @override
  String get ofPages => '共';

  @override
  String get goToPage => '跳转到页面';

  @override
  String get pageNumber => '页码';

  @override
  String get invalidPage => '无效的页码';

  @override
  String get share => '分享';

  @override
  String get export => '导出';

  @override
  String get print => '打印';

  @override
  String get download => '下载';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get ok => '确定';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get pleaseWait => '请稍候...';

  @override
  String get done => '完成';

  @override
  String get save => '保存';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get remove => '移除';
}
