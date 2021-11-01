import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class I18n implements WidgetsLocalizations {
  const I18n();

  static I18n current;

  static const GeneratedLocalizationsDelegate delegate =
      GeneratedLocalizationsDelegate();

  static I18n of(BuildContext context) => Localizations.of<I18n>(context, I18n);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  String get home => "Home";

  String get share => "Share";

  String get about => "About";

  String get rate => "Rate Us";

  String get update => "Update Application";

  String get notification => "Notification";

  String get languages => "Languages";

  String get appLang => "App Language";

  String get descLang => "Select your preferred languages";

  String get whoops => "Whoops!";

  String get noInternet => "No internet connection";

  String get tryAgain => "Try Again";

  String get closeApp => "Close APP";

  String get sureCloseApp => "Are you sure want to quit this application ?";

  String get ok => "OK";

  String get cancel => "CANCEL";

  String get changeTheme => "Change Theme";

  String get customizeYourOwnWay => "Customize your own way";

  String get descriptionCustomize =>
      "FlyWeb give you the power of better UI  customization experience, It's easy to choose your own theme style and aply to your project. Bassed on your UI recruitment choose Toolbar style, left-rigth button action, app Theme, loader style.After that go back home to see the changes.";

  String get navigationBarStyle => "Navigation bar style";

  String get headerType => "Header type";

  String get leftButtonOption => "Left Button Option";

  String get rightButtonOption => "Right Button Option";

  String get colorGradient => "Color Gradient";

  String get colorSolid => "Color Solid";

  String get loadingAnimation => "Loading Animation";

  String get backToHomePage => "Back to HomePage";

  String get darkMode => "Dark mode";

  String get lightMode => "Light mode";


  String social(String type) {
    return type;
  }
}

class $es extends I18n {
  const $es();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "Hogar";

  @override
  String get share => "Compartir";

  @override
  String get about => "Acerca de";

  @override
  String get rate => "Nos califica";

  @override
  String get update => "Aplicación de actualización";

  @override
  String get notification => "Notificación";

  @override
  String get languages => "Idiomas";

  @override
  String get appLang => "Idioma de la aplicación";

  @override
  String get descLang => "Selecciona tus idiomas preferidos";

  @override
  String get whoops => "Whoops!";

  @override
  String get noInternet => "Sin conexión a Internet";

  @override
  String get tryAgain => "Inténtalo de nuevo";

  @override
  String get closeApp => "Cerrar app";

  @override
  String get sureCloseApp => "Seguro que quieres salir de esta aplicación?";

  @override
  String get ok => "Okay";

  @override
  String get cancel => "Cancelar";

  @override
  String get changeTheme => "Cambiar de tema";

  @override
  String get customizeYourOwnWay => "Customize your own way";

  @override
  String get descriptionCustomize =>
      "FlyWeb give you the power of better UI  customization experience, It's easy to choose your own theme style and aply to your project. Bassed on your UI recruitment choose Toolbar style, left-rigth button action, app Theme, loader style.After that go back home to see the changes.";

  @override
  String get navigationBarStyle => "Navigation bar style";

  @override
  String get headerType => "Header type";

  @override
  String get leftButtonOption => "Left Button Option";

  @override
  String get rightButtonOption => "Right Button Option";

  @override
  String get colorGradient => "Color Gradient";

  @override
  String get colorSolid => "Color Solid";

  @override
  String get loadingAnimation => "Loading Animation";

  @override
  String get backToHomePage => "Back to HomePage";

  @override
  String get darkMode => "Modo oscuro";

  @override
  String get lightMode => "Modo de luz";
}

class $fr extends I18n {
  const $fr();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "Accueil";

  @override
  String get share => "Partager";

  @override
  String get about => "À propos";

  @override
  String get rate => "Évaluez nous";

  @override
  String get update => "Mettre à jour l'application";

  @override
  String get notification => "Notification";

  @override
  String get languages => "Les Langues";

  @override
  String get appLang => "Langue de l'application";

  @override
  String get descLang => "Sélectionnez vos langues préférées";

  @override
  String get whoops => "Oups!";

  @override
  String get noInternet => "Pas de connexion Internet";

  @override
  String get tryAgain => "Réessayer";

  @override
  String get closeApp => "Fermer l'application";

  @override
  String get sureCloseApp => "Voulez-vous vraiment quitter cette application?";

  @override
  String get ok => "D'accord";

  @override
  String get cancel => "Annuler";

  @override
  String get changeTheme => "Change le thème";

  @override
  String get customizeYourOwnWay => "Personnalisez à votre guise";

  @override
  String get descriptionCustomize =>
      "FlyWeb vous offre la puissance d'une meilleure expérience de personnalisation de l'interface utilisateur.Il est facile de choisir votre propre style de thème et de répondre à votre projet. En fonction de votre recrutement dans l'interface utilisateur, choisissez le style de la barre d'outils, l'action du bouton de gauche, le thème de l'application, le style du chargeur. Ensuite, revenez à la maison pour voir les changements.";

  @override
  String get navigationBarStyle => "Style de barre de navigation";

  @override
  String get headerType => "Type d'en-tête";

  @override
  String get leftButtonOption => "Option bouton gauche";

  @override
  String get rightButtonOption => "Option bouton droit";

  @override
  String get colorGradient => "Dégradé de couleur";

  @override
  String get colorSolid => "Couleur solide";

  @override
  String get loadingAnimation => "Chargement de l'animation";

  @override
  String get backToHomePage => "Retour à la page d'accueil";

  @override
  String get darkMode => "Mode sombre";

  @override
  String get lightMode => "Mode claire";
}

class $pt extends I18n {
  const $pt();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "Casa";

  @override
  String get share => "Compartilhar";

  @override
  String get about => "Sobre";

  @override
  String get rate => "Nos avalie";

  @override
  String get update => "Atualizar aplicativo";

  @override
  String get notification => "Notificação";

  @override
  String get languages => "Línguas";

  @override
  String get appLang => "Idioma da aplicação";

  @override
  String get descLang => "Selecione seus idiomas preferidos";

  @override
  String get whoops => "Opa!";

  @override
  String get noInternet => "Sem conexão à Internet";

  @override
  String get tryAgain => "Repetir";

  @override
  String get closeApp => "Feche a aplicação";

  @override
  String get sureCloseApp => "Tem certeza de que deseja sair deste aplicativo?";

  @override
  String get ok => "OK";

  @override
  String get cancel => "Cancelar";

  @override
  String get changeTheme => "Mudar tema";

  @override
  String get customizeYourOwnWay => "Personalize o seu próprio caminho";

  @override
  String get descriptionCustomize =>
      "O FlyWeb oferece a você o poder de uma melhor experiência de personalização da interface do usuário. É fácil escolher seu próprio estilo de tema e aplicar ao seu projeto. Com base no recrutamento da interface do usuário, escolha Estilo da barra de ferramentas, ação do botão esquerdo, Tema do aplicativo, estilo do carregador. Depois disso, volte para casa para ver as alterações.";

  @override
  String get navigationBarStyle => "Estilo da barra de navegação";

  @override
  String get headerType => "Tipo de cabeçalho";

  @override
  String get leftButtonOption => "Opção Botão Esquerdo";

  @override
  String get rightButtonOption => "Opção Botão Direito";

  @override
  String get colorGradient => "Gradiente de cor";

  @override
  String get colorSolid => "Cor Sólida";

  @override
  String get loadingAnimation => "Carregando Animação";

  @override
  String get backToHomePage => "Voltar à página inicial";

  @override
  String get darkMode => "Modo escuro";

  @override
  String get lightMode => "Coloque a luz";
}

class $ar extends I18n {
  const $ar();

  @override
  TextDirection get textDirection => TextDirection.rtl;

  @override
  String get home => "الصفحة الرئيسية";

  @override
  String get share => "مشاركة التطبيق";

  @override
  String get about => "معلومات عنا";

  @override
  String get rate => "قيمنا";

  @override
  String get update => "تحديث التطبيق";

  @override
  String get notification => "تنبيهات";

  @override
  String get languages => "تغيير اللغة";

  @override
  String get appLang => "لغة التطبيق";

  @override
  String get descLang => "اختر لغتك المفضلة";

  @override
  String get whoops => "عفوًا!";

  @override
  String get noInternet => "لا يوجد اتصال بالإنترنت";

  @override
  String get tryAgain => "حاول مجددا";

  @override
  String get closeApp => "أغلق التطبيق";

  @override
  String get sureCloseApp => "هل تريد بالتأكيد اغلاق هذا التطبيق؟";

  @override
  String get ok => "حسنا";

  @override
  String get cancel => "إلغاء";

  @override
  String get changeTheme => "غير الخلفية";

  @override
  String get customizeYourOwnWay => "تخصيص طريقتك الخاصة";

  @override
  String get descriptionCustomize =>
      "يمنحك FlyWeb قوة تجربة تخصيص أفضل لواجهة المستخدم ، من السهل اختيار نمط السمة الخاص بك وبشكل ملائم لمشروعك. بناء على توظيف واجهة المستخدم الخاصة بك ، اختر نمط شريط الأدوات ، وإجراء الزر الأيسر ، وموضوع التطبيق ، ونمط اللودر ، وبعد ذلك عد إلى المنزل لرؤية التغييرات.";

  @override
  String get navigationBarStyle => "نمط شريط التنقل";

  @override
  String get headerType => "شريط الرأس";

  @override
  String get leftButtonOption => "خيار الزر الأيسر";

  @override
  String get rightButtonOption => "خيار الزر الأيمن";

  @override
  String get colorGradient => "التدرج اللون";

  @override
  String get colorSolid => "لون واحد";

  @override
  String get loadingAnimation => "اللودر";

  @override
  String get backToHomePage => "العودة إلى الصفحة الرئيسية";

  @override
  String get darkMode => "الوضع الداكن";

  @override
  String get lightMode => "الوضع الفاتح";

  @override
  String social(String type) {
    switch (type) {
      case "Facebook":
        return "فيسبوك";
      case "Youtube":
        return "يوتيوب";
      case "Skype":
        return "سكايب";
      case "Twitter":
        return "تويتر";
      case "WhatsApp":
        return "واتسآب";
      case "سناب شات":
        return "";
      case "Messanger":
        return "فيسبوك ماسنجر";
      case "Instagram":
        return "انستقرام";
      default:
        return type;
    }
  }
}

class $hi extends I18n {
  const $hi();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "घर";

  @override
  String get share => "शेयर";

  @override
  String get about => "के बारे में";

  @override
  String get rate => "हमें रेटिंग दें";

  @override
  String get update => "एप्लिकेशन अपडेट करें";

  @override
  String get notification => "अधिसूचना";

  @override
  String get languages => "बोली";

  @override
  String get appLang => "अनुप्रयोग भाषा";

  @override
  String get descLang => "अपनी पसंदीदा भाषाओं का चयन करें";

  @override
  String get whoops => "उफ़!";

  @override
  String get noInternet => "कोई इंटरनेट कनेक्शन नहीं";

  @override
  String get tryAgain => "पुन: प्रयास करें";

  @override
  String get closeApp => "एप्लिकेशन को बंद करें";

  @override
  String get sureCloseApp => "क्या आप वाकई इस ऐप को छोड़ना चाहते हैं?";

  @override
  String get ok => "ठीक है";

  @override
  String get cancel => "रद्द करने के लिए";

  @override
  String get changeTheme => "थीम बदलें";

  @override
  String get customizeYourOwnWay => "अपने तरीके से अनुकूलित करें";

  @override
  String get descriptionCustomize =>
      "FlyWeb आपको बेहतर UI अनुकूलन अनुभव की शक्ति प्रदान करता है, अपनी खुद की थीम शैली और अपनी परियोजना के लिए आसान चुनना आसान है। आपके UI रिक्रूटमेंट पर आधारित टूलबार स्टाइल, लेफ्ट-रिग बटन एक्शन, ऐप थीम, लोडर स्टाइल चुनें। इसके बाद परिवर्तनों को देखने के लिए घर वापस जाएं।";

  @override
  String get navigationBarStyle => "नेविगेशन बार शैली";

  @override
  String get headerType => "हेडर प्रकार";

  @override
  String get leftButtonOption => "बायाँ बटन विकल्प";

  @override
  String get rightButtonOption => "राइट बटन विकल्प";

  @override
  String get colorGradient => "रंग ढालना";

  @override
  String get colorSolid => "रंग ठोस";

  @override
  String get loadingAnimation => "लोड हो रहा है एनीमेशन";

  @override
  String get backToHomePage => "वापस मुख्य पृष्ठ पर";

  @override
  String get darkMode => "डार्क मोड";

  @override
  String get lightMode => "प्रकाश मोड";
}

class $de extends I18n {
  const $de();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "Zuhause";

  @override
  String get share => "Aktie";

  @override
  String get about => "Über";

  @override
  String get rate => "Bewerten Sie uns";

  @override
  String get update => "Anwendung aktualisieren";

  @override
  String get notification => "Benachrichtigung";

  @override
  String get languages => "Sprachen";

  @override
  String get appLang => "Anwendungssprache";

  @override
  String get descLang => "Wählen Sie Ihre bevorzugten Sprachen";

  @override
  String get whoops => "Hoppla!";

  @override
  String get noInternet => "Keine Internetverbindung";

  @override
  String get tryAgain => "Wiederholen";

  @override
  String get closeApp => "Schließen Sie die Anwendung";

  @override
  String get sureCloseApp =>
      "Sind Sie sicher, dass Sie diese App beenden möchten?";

  @override
  String get ok => "In Ordnung";

  @override
  String get cancel => "Abbrechen";

  @override
  String get changeTheme => "Thema ändern";

  @override
  String get customizeYourOwnWay => "Passen Sie Ihren eigenen Weg an";

  @override
  String get descriptionCustomize =>
      "FlyWeb bietet Ihnen die Möglichkeit einer besseren Anpassung der Benutzeroberfläche. Sie können ganz einfach Ihren eigenen Themenstil auswählen und sich auf Ihr Projekt einstellen. Wählen Sie bei der Einstellung Ihrer Benutzeroberfläche den Symbolleistenstil, die Aktion mit der linken Maustaste, das App-Thema und den Laderstil aus. Danach kehren Sie nach Hause zurück, um die Änderungen anzuzeigen.";

  @override
  String get navigationBarStyle => "Stil der Navigationsleiste";

  @override
  String get headerType => "Headertyp";

  @override
  String get leftButtonOption => "Option für linke Taste";

  @override
  String get rightButtonOption => "Option mit der rechten Taste";

  @override
  String get colorGradient => "Farbverlauf";

  @override
  String get colorSolid => "Farbe fest";

  @override
  String get loadingAnimation => "Animation laden";

  @override
  String get backToHomePage => "Zurück zur Startseite";

  @override
  String get darkMode => "Dunkler Modus";

  @override
  String get lightMode => "Lichtmodus";
}

class $it extends I18n {
  const $it();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "Accoglienza";

  @override
  String get share => "Suddividere";

  @override
  String get about => "Di";

  @override
  String get rate => "Valutaci";

  @override
  String get update => "Aggiorna applicazione";

  @override
  String get notification => "Notifica";

  @override
  String get languages => "Le lingue";

  @override
  String get appLang => "Lingua dell'applicazione";

  @override
  String get descLang => "Seleziona le tue lingue preferite";

  @override
  String get whoops => "Spiacenti!";

  @override
  String get noInternet => "Nessuna connessione internet";

  @override
  String get tryAgain => "Riprova";

  @override
  String get closeApp => "Chiudi l'applicazione";

  @override
  String get sureCloseApp => "Sei sicuro di voler uscire da questa app?";

  @override
  String get ok => "Va bene";

  @override
  String get cancel => "Per cancellare";

  @override
  String get changeTheme => "Cambia tema";

  @override
  String get customizeYourOwnWay => "Personalizza a modo tuo";

  @override
  String get descriptionCustomize =>
      "FlyWeb ti dà la potenza di una migliore esperienza di personalizzazione dell'interfaccia utente, è facile scegliere il tuo stile del tema e applicare al tuo progetto. Scegli la tua barra degli strumenti come stile della barra degli strumenti, azione del pulsante a destra, tema dell'app, stile del caricatore e poi torna a casa per vedere le modifiche.";

  @override
  String get navigationBarStyle => "Stile della barra di navigazione";

  @override
  String get headerType => "Tipo di intestazione";

  @override
  String get leftButtonOption => "Opzione pulsante sinistro";

  @override
  String get rightButtonOption => "Opzione pulsante destro";

  @override
  String get colorGradient => "Sfumatura di colore";

  @override
  String get colorSolid => "Colore solido";

  @override
  String get loadingAnimation => "Caricamento animazione";

  @override
  String get backToHomePage => "Torna alla HomePage";

  @override
  String get darkMode => "Modalità scura";

  @override
  String get lightMode => "Modalità luce";
}

class $tr extends I18n {
  const $tr();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "Ev";

  @override
  String get share => "Paylaş";

  @override
  String get about => "Hakkında";

  @override
  String get rate => "Bizi değerlendirin";

  @override
  String get update => "Programmany täzeläň";

  @override
  String get notification => "Bildirim";

  @override
  String get languages => "Diller";

  @override
  String get appLang => "Uygulama dili";

  @override
  String get descLang => "Tercih ettiğiniz dilleri seçin";

  @override
  String get whoops => "Hata!";

  @override
  String get noInternet => "İnternet bağlantısı yok";

  @override
  String get tryAgain => "Yeniden Dene";

  @override
  String get closeApp => "Uygulamayı kapatın";

  @override
  String get sureCloseApp =>
      "Bu uygulamadan çıkmak istediğinizden emin misiniz?";

  @override
  String get ok => "Tamam";

  @override
  String get cancel => "İptal etmek";

  @override
  String get changeTheme => "Temayı değiştir";

  @override
  String get customizeYourOwnWay => "Kendi tarzınızı özelleştirin";

  @override
  String get descriptionCustomize =>
      "FlyWeb size daha iyi UI özelleştirme deneyiminin gücünü verir, Kendi tema stilinizi seçmek ve projenize uymak kolaydır. Kullanıcı arayüzü işe alımınıza dayanarak, Araç Çubuğu stilini, soldaki düğme eylemini, uygulama Temasını, yükleyici stilini seçin.Daha sonra değişiklikleri görmek için eve dönün.";

  @override
  String get navigationBarStyle => "Gezinme çubuğu stili";

  @override
  String get headerType => "Üstbilgi türü";

  @override
  String get leftButtonOption => "Sol Düğme Seçeneği";

  @override
  String get rightButtonOption => "Sağ Düğme Seçeneği";

  @override
  String get colorGradient => "Renk gradyanı";

  @override
  String get colorSolid => "Renk Düz";

  @override
  String get loadingAnimation => "Animasyon Yükleniyor";

  @override
  String get backToHomePage => "Ana sayfaya geri dön";

  @override
  String get darkMode => "karanlık mod";

  @override
  String get lightMode => "ışık modu";
}

class $ru extends I18n {
  const $ru();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get home => "Главная";

  @override
  String get share => "Поделиться";

  @override
  String get about => "О приложении";

  @override
  String get rate => "Оцените нас";

  @override
  String get update => "Обновить приложение";

  @override
  String get notification => "Уведомление";

  @override
  String get languages => "Языки";

  @override
  String get appLang => "Язык приложения";

  @override
  String get descLang => "Выберите предпочитаемый язык";

  @override
  String get whoops => "Упс!";

  @override
  String get noInternet => "Нет соединения с интернетом";

  @override
  String get tryAgain => "Попробуйте снова";

  @override
  String get closeApp => "Закрыть приложение";

  @override
  String get sureCloseApp =>
      "Вы уверены, что хотите выйти из этого приложения?";

  @override
  String get ok => "OK";

  @override
  String get cancel => "ОТМЕНА";

  @override
  String get changeTheme => "Сменить тему";

  @override
  String get customizeYourOwnWay => "Настроить по своему вкусу";

  @override
  String get descriptionCustomize =>
      "FlyWeb предоставляет Вам мощный инструмент для настройки пользовательского интерфейса. Вы можете легко подобрать свой собственный стиль темы и также с лёгкостью применить его к своему проекту. В зависимости от вашего набора пользовательского интерфейса выберите стиль панели инструментов, действие левой кнопки, тему приложения, стиль загрузки приложения. После, вернитесь на главную, чтобы увидеть изменения.";

  @override
  String get navigationBarStyle => "Стиль панели навигации";

  @override
  String get headerType => "Тип заголовка";

  @override
  String get leftButtonOption => "Настройка левой кнопки";

  @override
  String get rightButtonOption => "Настройка правой кнопки";

  @override
  String get colorGradient => "Градиент";

  @override
  String get colorSolid => "Цвет";

  @override
  String get loadingAnimation => "Анимация загрузки";

  @override
  String get backToHomePage => "Вернуться на главную";

  @override
  String get darkMode => "темный режим";

  @override
  String get lightMode => "световой режим";
}

class $en extends I18n {
  const $en();
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<I18n> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("en", ""),
      Locale("es", ""),
      Locale("fr", ""),
      Locale("ar", ""),
      Locale("pt", ""),
      Locale("hi", ""),
      Locale("de", ""),
      Locale("it", ""),
      Locale("tr", ""),
      Locale("ru", ""),
    ];
  }

  LocaleListResolutionCallback listResolution(
      {Locale fallback, bool withCountry = true}) {
    return (List<Locale> locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution(
      {Locale fallback, bool withCountry = true}) {
    return (Locale locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported, withCountry);
    };
  }

  @override
  Future<I18n> load(Locale locale) {
    final String lang = getLang(locale);
    if (lang != null) {
      switch (lang) {
        case "en":
          I18n.current = const $en();
          return SynchronousFuture<I18n>(I18n.current);
        case "es":
          I18n.current = const $es();
          return SynchronousFuture<I18n>(I18n.current);
        case "fr":
          I18n.current = const $fr();
          return SynchronousFuture<I18n>(I18n.current);
        case "pt":
          I18n.current = const $pt();
          return SynchronousFuture<I18n>(I18n.current);
        case "ar":
          I18n.current = const $ar();
          return SynchronousFuture<I18n>(I18n.current);
        case "hi":
          I18n.current = const $hi();
          return SynchronousFuture<I18n>(I18n.current);
        case "de":
          I18n.current = const $de();
          return SynchronousFuture<I18n>(I18n.current);
        case "it":
          I18n.current = const $it();
          return SynchronousFuture<I18n>(I18n.current);
        case "tr":
          I18n.current = const $tr();
          return SynchronousFuture<I18n>(I18n.current);
        case "ru":
          I18n.current = const $ru();
          return SynchronousFuture<I18n>(I18n.current);
        default:
        // NO-OP.
      }
    }
    I18n.current = const I18n();
    return SynchronousFuture<I18n>(I18n.current);
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Internal method to resolve a locale from a list of locales.
  ///
  Locale _resolve(Locale locale, Locale fallback, Iterable<Locale> supported,
      bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale locale, bool withCountry) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        // Language must always match both locales.
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }

        // If country code matches, return this locale.
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }

        // If no country requirement is requested, check if this locale has no country.
        if (true != withCountry &&
            (supportedLocale.countryCode == null ||
                supportedLocale.countryCode.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}

String getLang(Locale l) => l == null
    ? null
    : l.countryCode != null && l.countryCode.isEmpty
        ? l.languageCode
        : l.toString();
