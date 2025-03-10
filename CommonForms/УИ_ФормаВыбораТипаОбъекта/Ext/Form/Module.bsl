﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Параметры.Свойство("ТипыДляКонсолиЗапросов", _ТипыДляКонсолиЗапросов);
	Параметры.Свойство("ПоказыватьПростыеТипы", _ПоказыватьПростыеТипы);
	Параметры.Свойство("ПоказыватьПеречисления", _ПоказыватьПеречисления);
	Параметры.Свойство("ПереченьРазделов", _ПереченьРазделов);

	Значение = Неопределено;
	Если Параметры.Свойство("ТипыДляЗаполненияЗначений", Значение) И Значение = Истина Тогда
		_ПоказыватьПростыеТипы = Истина;
		_ПоказыватьПеречисления = Истина;
	КонецЕсли;

	Если _ТипыДляКонсолиЗапросов Тогда
		_ПоказыватьПеречисления = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	СтрокиДЗ = ДеревоОбъектов.ПолучитьЭлементы();
	СтрокиДЗ.Очистить();

	Если _ПоказыватьПростыеТипы Или _ТипыДляКонсолиЗапросов Тогда
		КореньДЗ = СтрокиДЗ.Добавить();
		КореньДЗ.Имя = "ПростыеТипы";

		Струк = Новый Структура("Число, Строка, Дата, Булево");
		Если _ТипыДляКонсолиЗапросов Тогда
			Струк.Вставить("СписокЗначений");
		КонецЕсли;

		СтрокиДЗ = КореньДЗ.ПолучитьЭлементы();

		Для Каждого Элем Из Струк Цикл
			СтрДЗ = СтрокиДЗ.Добавить();
			СтрДЗ.Имя = Элем.Ключ;
			СтрДЗ.ПолноеИмя = Элем.Ключ;
		КонецЦикла;

		Элементы.ДеревоОбъектов.Развернуть(КореньДЗ.ПолучитьИдентификатор(), Ложь);
		СтрокиДЗ = ДеревоОбъектов.ПолучитьЭлементы();
	КонецЕсли;

	КореньДЗ = СтрокиДЗ.Добавить();
	КореньДЗ.Имя = "Конфигурация";
	
	//ПереченьРазделов = "ПланыОбмена, Справочники, Документы, ПланыВидовХарактеристик, ПланыВидовРасчета, ПланыСчетов, БизнесПроцессы, Задачи";
	//!!! ПланыОбмена надо дорабатывать (отключил) !!!

	ПереченьРазделов = "ПланыОбмена, Справочники, Документы, ПланыВидовХарактеристик, ПланыВидовРасчета, ПланыСчетов, БизнесПроцессы, Задачи";
	Если _ПоказыватьПеречисления Тогда
		ПереченьРазделов = "ПланыОбмена, Справочники, Документы, Перечисления, ПланыВидовХарактеристик, ПланыВидовРасчета, ПланыСчетов, БизнесПроцессы, Задачи";
	КонецЕсли;

	Если Не ПустаяСтрока(_ПереченьРазделов) Тогда
		ПереченьРазделов = _ПереченьРазделов;
	КонецЕсли;

	СтрукРазделы = Новый Структура(ПереченьРазделов);
	СтрокиДЗ = КореньДЗ.ПолучитьЭлементы();
	Для Каждого Элем Из СтрукРазделы Цикл
		СтрДЗ = СтрокиДЗ.Добавить();
		СтрДЗ.Имя = Элем.Ключ;
		СтрДЗ.ПолучитьЭлементы().Добавить();
	КонецЦикла;

	Элементы.ДеревоОбъектов.Развернуть(КореньДЗ.ПолучитьИдентификатор(), Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьОбъект(Команда)
	ТекДанные = Элементы.ДеревоОбъектов.ТекущиеДанные;

	Если ТекДанные <> Неопределено И Не ПустаяСтрока(ТекДанные.ПолноеИмя) Тогда
		Значение = Неопределено;
		ИмяРаздела = ТекДанные.ПолучитьРодителя().Имя;

		Если ИмяРаздела = "ПростыеТипы" Тогда
			Если ТекДанные.Имя = "Число" Тогда
				Значение = 0;
			ИначеЕсли ТекДанные.Имя = "Строка" Тогда
				Значение = "";
			ИначеЕсли ТекДанные.Имя = "Дата" Тогда
				Значение = '00010101';
			ИначеЕсли ТекДанные.Имя = "Булево" Тогда
				Значение = Ложь;
			ИначеЕсли ТекДанные.Имя = "СписокЗначений" Тогда
				Значение = Новый СписокЗначений;
			Иначе
				Значение = Неопределено;
			КонецЕсли;
		Иначе
			ИмяРаздела = Лев(ИмяРаздела, Найти(ИмяРаздела, " ") - 1);
			Значение = вВычислитьВыражениеСервер(ИмяРаздела + "." + ТекДанные.Имя + ".ПустаяСсылка()");
		КонецЕсли;

		Если Значение <> Неопределено Тогда
			ОповеститьОВыборе(Значение);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоОбъектовПередРазворачиванием(Элемент, Строка, Отказ)
	УзелДЗ = ДеревоОбъектов.НайтиПоИдентификатору(Строка);
	СтрокиДЗ = УзелДЗ.ПолучитьЭлементы();
	Если СтрокиДЗ.Количество() = 1 И ПустаяСтрока(СтрокиДЗ[0].Имя) Тогда
		Отказ = Истина;
		СтрокиДЗ.Очистить();
		вЗаполнитьРазделМД(Строка);
		Элементы.ДеревоОбъектов.Развернуть(Строка);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура вЗаполнитьРазделМД(Строка)
	УзелДЗ = ДеревоОбъектов.НайтиПоИдентификатору(Строка);
	СтрокиДЗ = УзелДЗ.ПолучитьЭлементы();
	СтрокиДЗ.Очистить();

	ТипСтрока = Новый ОписаниеТипов("Строка");

	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("Имя", ТипСтрока);
	Таблица.Колонки.Добавить("Синоним", ТипСтрока);
	Таблица.Колонки.Добавить("ПолноеИмя", ТипСтрока);

	Для Каждого Элем Из Метаданные[УзелДЗ.Имя] Цикл
		Стр = Таблица.Добавить();
		Стр.Имя = Элем.Имя;
		Стр.Синоним = Элем.Представление();
		Стр.ПолноеИмя = Элем.ПолноеИмя();
	КонецЦикла;

	Таблица.Сортировать("Имя");
	УзелДЗ.Имя = УзелДЗ.Имя + " (" + Таблица.Количество() + ")";

	Для Каждого Стр Из Таблица Цикл
		СтрДЗ = СтрокиДЗ.Добавить();
		ЗаполнитьЗначенияСвойств(СтрДЗ, Стр);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоОбъектовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТекДанные = ДеревоОбъектов.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если ТекДанные <> Неопределено И Не ПустаяСтрока(ТекДанные.ПолноеИмя) Тогда
		Если Не ПустаяСтрока(ТекДанные.ПолноеИмя) Тогда
			СтандартнаяОбработка = Ложь;
			ВыбратьОбъект(Неопределено);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция вВычислитьВыражениеСервер(Формула)
	Попытка
		Результат = Вычислить(Формула);
	Исключение
		Результат = Неопределено;
	КонецПопытки;

	Возврат Результат;
КонецФункции