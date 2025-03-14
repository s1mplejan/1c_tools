﻿&После("ПриОпределенииВидовПодключаемыхКоманд")
Процедура УИ_ПриОпределенииВидовПодключаемыхКоманд(ВидыПодключаемыхКоманд)
	Если Не УИ_ОбщегоНазначения.ЕстьПравоНаИспользованиеИнструментов() Тогда
		Возврат;
	КонецЕсли;
	Вид = ВидыПодключаемыхКоманд.Добавить();
	Вид.Имя         = "УИ_УниверсальныеИнструменты";
	Вид.ИмяПодменю  = "УИ_УниверсальныеИнструменты";
	Вид.Заголовок   = НСтр("ru = 'Инструменты'");
	Вид.Картинка    = БиблиотекаКартинок.УИ_ПодсистемаУниверсальныеИнструмены;
	Вид.Отображение = ОтображениеКнопки.Картинка;
	Вид.Порядок = 1;
	Вид.ВидГруппыФормы=ВидГруппыФормы.Подменю;
КонецПроцедуры

&После("ПриОпределенииКомандПодключенныхКОбъекту")
Процедура УИ_ПриОпределенииКомандПодключенныхКОбъекту(НастройкиФормы, Источники, ПодключенныеОтчетыИОбработки, Команды)
	Если Не УИ_ОбщегоНазначения.ЕстьПравоНаИспользованиеИнструментов() Тогда
		Возврат;
	КонецЕсли;
	Команда = Команды.Добавить();
	Команда.Вид="УИ_УниверсальныеИнструменты";
	Команда.Идентификатор="УИ_СравнениеОбъектов";
	Команда.Представление="Сравнить объекты";
	Команда.ТипПараметра=УИ_ОбщегоНазначенияПовтИсп.ОписаниеТипаВсеСсылки();
	Команда.Назначение="ДляСписка";
	Команда.ИзменяетВыбранныеОбъекты=Ложь;
	Команда.МножественныйВыбор=Истина;
	//		Команда.Менеджер = "Обработка.УИ_СравнениеОбъектов";
	Команда.ИмяФормы = "Обработка.УИ_СравнениеОбъектов.Форма";
	Команда.ИмяПараметраФормы = "СравниваемыеОбъекты";
	Команда.Порядок=0;

	Команда = Команды.Добавить();
	Команда.Вид="УИ_УниверсальныеИнструменты";
	Команда.Идентификатор="УИ_ДобавитьКСравнению";
	Команда.Представление="Добавить к сравнению";
	Команда.ТипПараметра=УИ_ОбщегоНазначенияПовтИсп.ОписаниеТипаВсеСсылки();
	Команда.ИзменяетВыбранныеОбъекты=Ложь;
	Команда.МножественныйВыбор=Истина;
	Команда.Обработчик = "УИ_ОбщегоНазначенияКлиент.ДобавитьОбъектыКСравнению";
	Команда.Порядок=1;

	Команда = Команды.Добавить();
	Команда.Вид="УИ_УниверсальныеИнструменты";
	Команда.Идентификатор="УИ_ВыгрузитьОбъектыВXML";
	Команда.Представление="Выгрузить объекты в XML";
	Команда.ТипПараметра=УИ_ОбщегоНазначенияПовтИсп.ОписаниеТипаВсеСсылки();
	Команда.ИзменяетВыбранныеОбъекты=Ложь;
	Команда.МножественныйВыбор=Истина;
	Команда.Картинка=БиблиотекаКартинок.УИ_РезультатВыгрузки;
	Команда.Обработчик = "УИ_ОбщегоНазначенияКлиент.ВыгрузитьОбъектыВXML";
	Команда.Порядок=1;

	Команда = Команды.Добавить();
	Команда.Вид="УИ_УниверсальныеИнструменты";
	Команда.Идентификатор="УИ_РедактироватьОбъект";
	Команда.Представление="Редактировать объект";
	Команда.ТипПараметра=УИ_ОбщегоНазначенияПовтИсп.ОписаниеТипаВсеСсылки();
	Команда.ИзменяетВыбранныеОбъекты=Ложь;
	Команда.МножественныйВыбор=Ложь;
	Команда.Картинка=БиблиотекаКартинок.УИ_РедакторОбъектовБазыДанных;
	Команда.Обработчик = "УИ_ОбщегоНазначенияКлиент.ОбработчикКомандыРедактироватьОбъект";
	Команда.Порядок=2;
	
	Команда = Команды.Добавить();
	Команда.Вид="УИ_УниверсальныеИнструменты";
	Команда.Идентификатор="УИ_ПоискСсылокНаОбъект";
	Команда.Представление="Найти ссылки объект";
	Команда.ТипПараметра=УИ_ОбщегоНазначенияПовтИсп.ОписаниеТипаВсеСсылки();
	Команда.ИзменяетВыбранныеОбъекты=Ложь;
	Команда.МножественныйВыбор=Ложь;
	Команда.Картинка=БиблиотекаКартинок.НайтиВСодержании;
	Команда.Обработчик = "УИ_ОбщегоНазначенияКлиент.ОбработчикКомандыНайтиСсылкиНаОбъект";
	Команда.Порядок=3;
	
КонецПроцедуры