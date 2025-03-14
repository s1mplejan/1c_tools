﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	КопироватьДанныеФормы(Параметры.Объект, Объект);
	
	АдресРезультатаЗапроса = Параметры.АдресРезультатаЗапроса;
	ИндексРезультата = Параметры.РезультатВПакете - 1;
	
	Обработка = РеквизитФормыВЗначение("Объект");
	
	ДоляОтображенияТяжелых = Обработка.СохраняемыеСостояния_Получить("ДоляОтображенияТяжелых", 30);
	ОтображатьВТерминах1С = Обработка.СохраняемыеСостояния_Получить("ОтображатьВТерминах1С", Истина);
	
	ПланПрочитан = ПолучитьПланЗапросаИзЖурнала();
																	 
КонецПроцедуры

&НаСервере
Функция ПолучитьПланЗапросаИзЖурнала()
	
	Обработка = РеквизитФормыВЗначение("Объект");
	
	стРезультатЗапроса = ПолучитьИзВременногоХранилища(АдресРезультатаЗапроса);
	маРезультатЗапроса = стРезультатЗапроса.Результат;
	стРезультат = маРезультатЗапроса[ИндексРезультата];
	
	СтрокаСобытияТЖ = Обработка.ТехнологическийЖурнал_ПолучитьИнформациюПоЗапросу(стРезультат.ЗапросИД, 
	                                                                 стРезультат.ВремяНачалаЗапроса, стРезультат.ДлительностьВМиллисекундах);
	ТекстСобытияЖурнала.УстановитьТекст(СтрокаСобытияТЖ);
	
	маТекстыСобытий = Новый Массив;
	маСобытия = Новый Массив;
	чСтрока = 1;
	Пока Истина Цикл
		
		стСобытие = ТехнологическийЖурнал_НайтиСобытиеПоСтрокам(ТекстСобытияЖурнала, чСтрока);
		
		Если стСобытие = Неопределено Тогда
			Прервать;
		КонецЕсли;
		
		чСтрока = стСобытие.КонечнаяСтрока + 1;
	
		маТекстСобытия = Новый Массив;
		Для й = стСобытие.НачальнаяСтрока По стСобытие.КонечнаяСтрока Цикл
			маТекстСобытия.Добавить(ТекстСобытияЖурнала.ПолучитьСтроку(й));
		КонецЦикла;
		
		ТекстСобытия = СтрСоединить(маТекстСобытия, "
		                                              |");
		
		стСобытие = ТехнологическийЖурнал_РазобратьСобытие(ТекстСобытия);
		
		ТекстЗапросаСУБД = Неопределено;
		Если НЕ стСобытие.Свойство("Sql", ТекстЗапросаСУБД) Тогда
			Продолжить;
		КонецЕсли;
		
		Если ТекстЗапросаСУБД = "COMMIT TRANSACTION" Тогда
			Продолжить;
		КонецЕсли;
		
		Если НЕ стСобытие.Свойство("planSQLText") Тогда
			Продолжить;
		КонецЕсли;
		
		маТекстыСобытий.Добавить(ТекстСобытия);
		маСобытия.Добавить(стСобытие);
		
	КонецЦикла;
	
	Если маСобытия.Количество() < 1 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	РазделительПланов = "
		|=====================================================================================================================================
		|";
	
	Для Каждого Событие Из маСобытия Цикл
		
		ДанныеТерминов = Неопределено;
		ДобавитьТекстЗапроса(ДанныеТерминов);
		
		Если ПланТекстовый.КоличествоСтрок() > 0 Тогда
			ПланТекстовый.ДобавитьСтроку(РазделительПланов);
			ПланТекстовый1С.ДобавитьСтроку(РазделительПланов);
		КонецЕсли;
		
		Если Событие.DBMS = "DBMSSQL" Тогда
			ДобавитьПланЗапроса_DBMSSQL(ДанныеТерминов);
		ИначеЕсли Событие.DBMS = "DBPOSTGRS" Тогда
			ДобавитьПланЗапроса_DBPOSTGRS(ДанныеТерминов);
		Иначе
			СтрокаОшибки = СтрШаблон("Получение плана запроса для СУБД ""%1"" не поддерживается.", Событие.DBMS);
			ПланТекстовый.УстановитьТекст(СтрокаОшибки);
			ПланТекстовый1С.УстановитьТекст(СтрокаОшибки);
		КонецЕсли;
		
	КонецЦикла;
	
	РассчитатьСтоимостиИДорогиеСтроки();

	Возврат Истина;

КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция УбратьКавычки(Строка, СимволКавычек = Неопределено)
	
	Если СимволКавычек = Неопределено Тогда
		Возврат УбратьКавычки(УбратьКавычки(Строка, "'"), """");
	КонецЕсли;
	
	Если Лев(Строка, 1) = СимволКавычек Тогда
		Результат = Прав(Строка, СтрДлина(Строка) - 1);
	Иначе
		Результат = Строка;
	КонецЕсли;
	
	Если Прав(Результат, 1) = СимволКавычек Тогда
		Возврат Лев(Результат, СтрДлина(Результат) - 1);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции


&НаСервереБезКонтекста
Функция ДобавитьРазделительЗапросовЕслиНеПустой(Текст)
	
	Если ПустаяСтрока(Текст) Тогда
		Возврат Текст;
	КонецЕсли;
	
	Возврат Текст + ";
	|////////////////////////////////////////////////////////////////////////////////
	|";
	
КонецФункции

&НаСервере
Процедура ДобавитьТекстЗапроса(ДанныеТерминов)
	Перем ТекстСвойства, ТекстПараметров;
	
	Обработка = РеквизитФормыВЗначение("Объект");
	
	Если Событие.Свойство("Sql", ТекстСвойства) Тогда
		ТекстСвойства = УбратьКавычки(ТекстСвойства);
		ТекстЗапроса = ДобавитьРазделительЗапросовЕслиНеПустой(ТекстЗапроса) + ТекстСвойства;
		ТекстЗапросаВТерминах1С = ДобавитьРазделительЗапросовЕслиНеПустой(ТекстЗапросаВТерминах1С) + Обработка.SQLЗапросВТермины1С(ТекстСвойства, ДанныеТерминов);
	КонецЕсли;
	
	Если Событие.Свойство("Prm", ТекстПараметров) Тогда
		ПараметрыЗапроса = ДобавитьРазделительЗапросовЕслиНеПустой(ПараметрыЗапроса) + УбратьКавычки(ТекстПараметров);
		Элементы.СтраницаПараметрыЗапроса.Видимость = Истина;
	Иначе
		Элементы.СтраницаПараметрыЗапроса.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьЧисло(Знач Значение)
	
	Если ТипЗнч(Значение) = Тип("Строка") Тогда
		
		Значение = СокрЛП(Значение);
		ъ = СтрНайти(Значение, "E");
		Если ъ > 0 Тогда
			Мантисса = Число(Лев(Значение, ъ - 1));
			Порядок = Число(Прав(Значение, СтрДлина(Значение) - ъ));
			Ч = Мантисса * Pow(10, Порядок);
		Иначе
			Ч = Число(Значение);
		КонецЕсли;
		
	Иначе
		
		Ч  = Значение;
		
	КонецЕсли;
	
	Возврат Ч;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ФорматироватьЧисло(Ч, Точность, ДесятичныйРазделитель = ",")
	
	ДлинаРезультата = ?(Точность.Точность > 0, Точность.Длина + 1, Точность.Длина);
	
	Если Ч = 0 Тогда
		ДлинаЦелойЧасти = 1;
	ИначеЕсли Ч > 0 Тогда
		ДлинаЦелойЧасти = Цел(Log10(Ч)) + 1;
	Иначе
		ДлинаЦелойЧасти = Цел(Log10(-Ч)) + 1;
	КонецЕсли;
	
	Если ДлинаЦелойЧасти > Точность.Длина - Точность.Точность Тогда
		Возврат Лев("##############################", ДлинаРезультата);
	КонецЕсли;
	
	ПредставлениеЧисла = Формат(Ч, СтрШаблон("ЧЦ=%1; ЧДЦ=%2; ЧН=; ЧГ=; ЧРД=%3", Точность.Длина, Точность.Точность, ДесятичныйРазделитель));
			
	Возврат Лев("                              ", ДлинаРезультата - СтрДлина(ПредставлениеЧисла)) + ПредставлениеЧисла;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция Точность_Инициализировать(Длина = 1, Точность = 0)
	Возврат Новый Структура("Длина, Точность", Длина, Точность);
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура Точность_ДобавитьЗначение(Точность, Знач Ч)
	
	Если Ч < 0 Тогда
		Ч = -Ч;
	КонецЕсли;
	
	Если Ч < 1 Тогда
		ДлинаЦелойЧасти = 1;
	Иначе
		ДлинаЦелойЧасти = Цел(Log10(Ч)) + 1;
	КонецЕсли;
	
	Н = Ч;
	ДлинаДробнойЧасти = 15;
	Для й = 0 По ДлинаДробнойЧасти Цикл
		Если Н = Цел(Н) Тогда
			ДлинаДробнойЧасти = й;
			Прервать;
		КонецЕсли;
		Н = Н * 10;
	КонецЦикла;
	
	ДлинаЦелойЧасти = Макс(ДлинаЦелойЧасти, Точность.Длина - Точность.Точность);
	ДлинаДробнойЧасти = Макс(ДлинаДробнойЧасти, Точность.Точность);
	
	Точность.Длина = ДлинаЦелойЧасти + ДлинаДробнойЧасти;
	Точность.Точность = ДлинаДробнойЧасти;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьПланЗапроса_DBMSSQL(ДанныеТерминов)
	
	Обработка = РеквизитФормыВЗначение("Объект");
	
	ТекстПлана = УбратьКавычки(Событие.planSQLText);
	
	ТекстПлан = Новый ТекстовыйДокумент;
	ТекстПлан.УстановитьТекст(ТекстПлана);
	
	Если ОтображатьВТерминах1С Тогда
		ТекстПланВТерминах1С = Новый ТекстовыйДокумент;
		ТекстПланВТерминах1С.УстановитьТекст(Обработка.SQLПланВТермины1С(ТекстПлана, ДанныеТерминов));
	КонецЕсли;
	
	й = 1;
	Пока й <= ТекстПлан.КоличествоСтрок() Цикл
		
		Если ЗначениеЗаполнено(ТекстПлан.ПолучитьСтроку(й)) Тогда
			й = й + 1;
		Иначе
			
			ТекстПлан.УдалитьСтроку(й);
			
			Если ОтображатьВТерминах1С Тогда
				ТекстПланВТерминах1С.УдалитьСтроку(й);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если ТекстПлан.КоличествоСтрок() < 1 Тогда
		Возврат;
	КонецЕсли;
	
	Строка = ТекстПлан.ПолучитьСтроку(1);
	Ъ = СтрНайти(Строка, "|");
	СтрокаПоказателей = Лев(Строка, Ъ - 1);
	чКоличествоПоказателей = СтрЧислоВхождений(СтрокаПоказателей, ",");
	
	СтрокаУзла = "|--";
	чДлинаУзла = СтрДлина(СтрокаУзла);
	
	ПланТекстовый.ДобавитьСтроку("(rows, executes, estimate rows, estimate i/o, estimate cpu, avg. row size, totat subtree cost, estimate executions, |-- operators...)");
	ПланТекстовый.ДобавитьСтроку("");

	соРодители = Новый Соответствие;
	ПредыдущийУзел = План;
	
	Точность_Rows = Точность_Инициализировать();
	Точность_Executes = Точность_Инициализировать();
	Точность_Estimate_rows = Точность_Инициализировать();
	Точность_Estimate_IO = Точность_Инициализировать(4, 3);
	Точность_Estimate_CPU = Точность_Инициализировать(4, 3);
	Точность_Avg_row_size = Точность_Инициализировать();
	Точность_Totat_subtree_cost = Точность_Инициализировать(4, 3);
	Точность_Estimate_executions = Точность_Инициализировать();
	
	маПданТекст = Новый Массив;
	
	чПредыдущийУровень = 0;
	Для й = 1 По ТекстПлан.КоличествоСтрок() Цикл
		
		Строка = ТекстПлан.ПолучитьСтроку(й);
		Ъ = СтрНайти(Строка, ",", , , чКоличествоПоказателей);
		СтрокаПоказателей = Лев(Строка, Ъ - 1);
		СтрокаОператоров = Прав(Строка, СтрДлина(Строка) - Ъ);
		
		маПоказатели = СтрРазделить(СтрокаПоказателей, ",");
		
		Ъ = СтрНайти(СтрокаОператоров, СтрокаУзла);
		СтрокаПропусков = Лев(СтрокаОператоров, Ъ - 1);
		стрОператоры = Прав(СтрокаОператоров, СтрДлина(СтрокаОператоров) - Ъ + 1 - чДлинаУзла);
		
		чУровень = СтрДлина(СтрокаПропусков);
		
		Если чУровень > чПредыдущийУровень Тогда
			Родитель = ПредыдущийУзел;
			соРодители[чУровень] = Родитель;
		ИначеЕсли чУровень < чПредыдущийУровень Тогда
			Родитель = соРодители[чУровень];
		КонецЕсли;
		
		НовыйУзел = Родитель.ПолучитьЭлементы().Добавить();
		НовыйУзел.ИсходныйОператор = стрОператоры;
		Если ОтображатьВТерминах1С Тогда
			СтрокаВТерминах1С = ТекстПланВТерминах1С.ПолучитьСтроку(й);
			Ъ = СтрНайти(СтрокаВТерминах1С, СтрокаУзла);
			НовыйУзел.Оператор = Прав(СтрокаВТерминах1С, СтрДлина(СтрокаВТерминах1С) - Ъ + 1 - чДлинаУзла);
		Иначе
			НовыйУзел.Оператор = стрОператоры;
		КонецЕсли;
		
		Rows = ПолучитьЧисло(маПоказатели[0]);                                    	
		Executes = ПолучитьЧисло(маПоказатели[1]);
		Estimate_rows = ПолучитьЧисло(маПоказатели[2]);
		Estimate_IO = ПолучитьЧисло(маПоказатели[3]);
		Estimate_CPU = ПолучитьЧисло(маПоказатели[4]);
		Avg_row_size = ПолучитьЧисло(маПоказатели[5]);
		Totat_subtree_cost = ПолучитьЧисло(маПоказатели[6]);
		Estimate_executions = ПолучитьЧисло(маПоказатели[7]);
		
		Точность_ДобавитьЗначение(Точность_Rows, Rows);
		Точность_ДобавитьЗначение(Точность_Executes, Executes);
		Точность_ДобавитьЗначение(Точность_Estimate_rows, Estimate_rows);
		Точность_ДобавитьЗначение(Точность_Estimate_IO, Estimate_IO);
		Точность_ДобавитьЗначение(Точность_Estimate_CPU, Estimate_CPU);
		Точность_ДобавитьЗначение(Точность_Avg_row_size, Avg_row_size);
		Точность_ДобавитьЗначение(Точность_Totat_subtree_cost, Totat_subtree_cost);
		Точность_ДобавитьЗначение(Точность_Estimate_executions, Estimate_executions);
		
		ДанныеОператора = Новый Структура(
			"Rows, Executes, Estimate_rows, Estimate_IO, Estimate_CPU, Avg_row_size, Totat_subtree_cost, Estimate_executions, СтрокаОператоров",
			Rows,
			Executes,
			Estimate_rows,
			Estimate_IO,
			Estimate_CPU,
			Avg_row_size,
			Totat_subtree_cost,
			Estimate_executions,
			СтрокаОператоров);
					
					
		маПданТекст.Добавить(ДанныеОператора);
		
		НовыйУзел.СтоимостьУзла = Totat_subtree_cost; 
		НовыйУзел.СтрокПлан = Estimate_rows;
		НовыйУзел.СтрокФакт = Rows; 
		НовыйУзел.ВызовыПлан = Estimate_executions;
		НовыйУзел.ВызовыФакт = Executes;
		НовыйУзел.ЗатратыВВ = Estimate_IO;
		НовыйУзел.ЗатратыЦП = Estimate_CPU;
		НовыйУзел.СреднийРазмерСтроки = Avg_row_size;
		
		ПредыдущийУзел = НовыйУзел;
		чПредыдущийУровень = чУровень;
		
	КонецЦикла;
	
	Для Каждого стДанныеОператора Из маПданТекст Цикл       
		
		СтрокаТекстовогоПлана = СтрШаблон("%1, %2, %3, %4, %5, %6, %7, %8, %9",
			ФорматироватьЧисло(стДанныеОператора.Rows, Точность_Rows, "."),
			ФорматироватьЧисло(стДанныеОператора.Executes, Точность_Executes, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_rows, Точность_Estimate_rows, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_IO, Точность_Estimate_IO, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_CPU, Точность_Estimate_CPU, "."),
			ФорматироватьЧисло(стДанныеОператора.Avg_row_size, Точность_Avg_row_size, "."),
			ФорматироватьЧисло(стДанныеОператора.Totat_subtree_cost, Точность_Totat_subtree_cost, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_executions, Точность_Estimate_executions, "."),
			стДанныеОператора.СтрокаОператоров);
			
		ПланТекстовый.ДобавитьСтроку(СтрокаТекстовогоПлана);
		
	КонецЦикла;
		
	ПланТекстовый1С.УстановитьТекст(Обработка.SQLПланВТермины1С(ПланТекстовый.ПолучитьТекст(), ДанныеТерминов));
	
	//РассчитатьСтоимостиИДорогиеСтроки();
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьПланЗапроса_DBPOSTGRS(ДанныеТерминов)
	
	Обработка = РеквизитФормыВЗначение("Объект");
	
	ТекстПлана = УбратьКавычки(Событие.planSQLText);
	
	ПланТекстовый.УстановитьТекст(ТекстПлана);
	ПланТекстовый1С.УстановитьТекст(Обработка.SQLПланВТермины1С(ТекстПлана, ДанныеТерминов, 1));
	
КонецПроцедуры

&НаСервере
Процедура РассчитатьСтоимостиИДорогиеСтроки(Узел = Неопределено, тзСтоимости = Неопределено)
	
	Если Узел = Неопределено Тогда
		Узел = План;
		тзСтоимости = Новый ТаблицаЗначений;
		тзСтоимости.Колонки.Добавить("СтоимостьОператора", Новый ОписаниеТипов("Число"));
		тзСтоимости.Колонки.Добавить("СтоимостьУзла", Новый ОписаниеТипов("Число"));
		тзСтоимости.Колонки.Добавить("Узел");
	КонецЕсли;
	
	ОбщаяСтоимость = 0;
	Для Каждого ПодчиненныйУзел Из Узел.ПолучитьЭлементы() Цикл
		
		РассчитатьСтоимостиИДорогиеСтроки(ПодчиненныйУзел, тзСтоимости);
		
		ОбщаяСтоимость = ОбщаяСтоимость + ПодчиненныйУзел.СтоимостьУзла;
		
	КонецЦикла;
	
	Если ТипЗнч(Узел) = Тип("ДанныеФормыЭлементДерева") Тогда
		
		СтоимостьОператора = Узел.СтоимостьУзла - ОбщаяСтоимость;
		Узел.СтоимостьОператора = ?(СтоимостьОператора < 0, 0, СтоимостьОператора);
		
		СтрокаСтоимости = тзСтоимости.Добавить();
		СтрокаСтоимости.Узел = Узел;
		СтрокаСтоимости.СтоимостьОператора = Узел.СтоимостьОператора;
		СтрокаСтоимости.СтоимостьУзла = Узел.СтоимостьУзла;
		
	Иначе
		
		Если тзСтоимости.Количество() > 0 Тогда
			
			тзИтоги = тзСтоимости.Скопировать();
			тзИтоги.Свернуть(, "СтоимостьОператора, СтоимостьУзла");
			чСтоимостьВсего = тзИтоги[0].СтоимостьОператора;
			
			Для Каждого Строка Из тзСтоимости Цикл
				Строка.Узел.СтоимостьОператораПроцент = СтрШаблон("%1%%", Формат(Строка.СтоимостьОператора * 100 / чСтоимостьВсего, "ЧЦ=5; ЧДЦ=2; ЧН="));
				Строка.Узел.СтоимостьУзлаПроцент = СтрШаблон("%1%%", Формат(Строка.СтоимостьУзла * 100 / чСтоимостьВсего, "ЧЦ=5; ЧДЦ=2; ЧН="));
			КонецЦикла;
			
			РасчитатьДорогиеСтроки(План);
			
		КонецЕсли;
	
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура РасчитатьДорогиеСтроки(Узел)
	
	тзСтоимости = Новый ТаблицаЗначений;
	тзСтоимости.Колонки.Добавить("Стоимость", Новый ОписаниеТипов("Число"));
	тзСтоимости.Колонки.Добавить("Узел");
	
	Если ТипЗнч(Узел) = Тип("ДанныеФормыЭлементДерева") Тогда
		СтоимостьКорня = Узел.СтоимостьОператора;
	Иначе
		СтоимостьКорня = 0;
	КонецЕсли;
	
	СтоимостьСумма = СтоимостьКорня;
	Для Каждого ПодчиненныйУзел Из Узел.ПолучитьЭлементы() Цикл
		СтрокаСтоимости = тзСтоимости.Добавить();
		СтрокаСтоимости.Узел = ПодчиненныйУзел;
		СтрокаСтоимости.Стоимость = ПодчиненныйУзел.СтоимостьУзла;
		СтоимостьСумма = СтоимостьСумма + СтрокаСтоимости.Стоимость;
	КонецЦикла;
	
	тзСтоимости.Сортировать("Стоимость Убыв");
	Отобразить = СтоимостьСумма * ДоляОтображенияТяжелых / 100 - СтоимостьКорня;
	
	Для Каждого Строка Из тзСтоимости Цикл
		Если Отобразить <= 0 Тогда
			Прервать;
		КонецЕсли;
		Строка.Узел.Выделено = Истина;
		РасчитатьДорогиеСтроки(Строка.Узел);
		Отобразить = Отобразить - Строка.Стоимость;                          	
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ТехнологическийЖурнал_НайтиСобытиеПоСтрокам(СобытиеЖурнала, чНачальнаяСтрокаПоиска = 1)
	
	Обработка = РеквизитФормыВЗначение("Объект");
	
	ШаблонСтрокиНачалаСобытия = Обработка.РегШаблон_ПолучитьОбъектШаблон("\d\d:\d\d.\d+-\d+,.*");
	
	чНачальнаяСтрока = Неопределено;
	Для й = чНачальнаяСтрокаПоиска По СобытиеЖурнала.КоличествоСтрок() Цикл
		Строка = СобытиеЖурнала.ПолучитьСтроку(й);
		Если Обработка.РегШаблон_Соответствует(Строка, ШаблонСтрокиНачалаСобытия) Тогда
			Если ЗначениеЗаполнено(чНачальнаяСтрока) Тогда
				чКонечнаяСтрока = й - 1;
				Прервать;
			Иначе
				чНачальнаяСтрока = й;
				чКонечнаяСтрока = СобытиеЖурнала.КОличествоСтрок();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если чНачальнаяСтрока = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	//маСвойства = СтрРазделить(Строка, ",");
	
	Возврат Новый Структура("НачальнаяСтрока, КонечнаяСтрока", чНачальнаяСтрока, чКонечнаяСтрока);
	
КонецФункции

&НаСервере
Функция ТехнологическийЖурнал_РазобратьСобытие(Знач СтрокаТехнологическогоЖурнала)
	
	стСобытие = Новый Структура;
	
	стСобытияСложноеЗначение = Новый Структура("Sql, Prm, planSQLText, Context", "Prm, Rows, Context, planSQLText", "RowsAffected, planSQLText", "Context, RowsAffected");
	Для Каждого кз Из стСобытияСложноеЗначение Цикл
		
		СтрокаПоиска = "," + кз.Ключ + "=";
		чНачальнаяПозиция = СтрНайти(СтрокаТехнологическогоЖурнала, СтрокаПоиска);
		
		Если чНачальнаяПозиция = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		чНачальнаяПозицияЗначения = чНачальнаяПозиция + СтрДлина(СтрокаПоиска);
		
		Если кз.Значение <> Неопределено Тогда
			
			чКонечнаяПозиция = 0;
			маСледИмена = СтрРазделить(кз.Значение, ",");
			Для Каждого СледующееИмя Из маСледИмена Цикл
				ч = СтрНайти(СтрокаТехнологическогоЖурнала, "," + СокрЛП(СледующееИмя) + "=", , чНачальнаяПозицияЗначения);
				Если ч > 0 И (чКонечнаяПозиция = 0 ИЛИ чКонечнаяПозиция > ч) Тогда
					чКонечнаяПозиция = ч;
				КонецЕсли;
			КонецЦикла;
			
		Иначе
			чКонечнаяПозиция = 0;
		КонецЕсли;
		
		Если чКонечнаяПозиция = 0 Тогда
			чКонечнаяПозиция = СтрДлина(СтрокаТехнологическогоЖурнала);
		КонецЕсли;
		
		стСобытие.Вставить(кз.Ключ, Сред(СтрокаТехнологическогоЖурнала, чНачальнаяПозицияЗначения, чКонечнаяПозиция - чНачальнаяПозицияЗначения));
		
		СтрокаТехнологическогоЖурнала = Лев(СтрокаТехнологическогоЖурнала, чНачальнаяПозиция) + Прав(СтрокаТехнологическогоЖурнала, СтрДлина(СтрокаТехнологическогоЖурнала) - чКонечнаяПозиция);
		
	КонецЦикла;
	
	маСвойства = СтрРазделить(СтрокаТехнологическогоЖурнала, ",");
	
	СтрокаВремяДлительность = маСвойства[0];
	
	чПозицияМинус = СтрНайти(СтрокаВремяДлительность, "-");
	стСобытие.Вставить("Длительность", Прав(СтрокаВремяДлительность, СтрДлина(СтрокаВремяДлительность) - чПозицияМинус));
	
	СтрокаВремя = Лев(СтрокаВремяДлительность, чПозицияМинус - 1);
	стСобытие.Вставить("Время", СтрокаВремя);
	
	стСобытие.Вставить("Событие", маСвойства[1]);
	стСобытие.Вставить("УровеньСобытия", Число(маСвойства[2]));
	
	Для й = 3 По маСвойства.ВГраница() Цикл
		
		СтрокаСвойства = маСвойства[й];
		чПозицияРавно = СтрНайти(СтрокаСвойства, "=");
		
		Если чПозицияРавно = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяСвойства = СтрЗаменить(Лев(СтрокаСвойства, чПозицияРавно - 1), ":", "_");
		стСобытие.Вставить(ИмяСвойства, Прав(СтрокаСвойства, СтрДлина(СтрокаСвойства) - чПозицияРавно));
		
	КонецЦикла;
	
	Возврат стСобытие;
	
КонецФункции

&НаКлиенте
Процедура ПланПриАктивизацииСтроки(Элемент)
	Если Элементы.План.ТекущиеДанные <> Неопределено Тогда
		ТекущийОператор = Элементы.План.ТекущиеДанные.Оператор;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если НЕ ПланПрочитан Тогда
		//Попробуем еще раз через секунду. Если пользователь очень шустрый, событие могло не успеть попасть в журнал.
		ПодключитьОбработчикОжидания("ОтложенноеЧтениеЖурнала", 1, Истина);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОтложенноеЧтениеЖурнала()
	
	ОбновитьПлан();
	
	Если НЕ ПланПрочитан Тогда
		Оповещение = Новый ОписаниеОповещения("ЗакрытиеПослеПредупреждения", ЭтаФорма);
		ПоказатьПредупреждение(Оповещение, "Не удалось получить информацию о запросе", , Объект.Заголовок);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытиеПослеПредупреждения(ДополнительныеПараметры) Экспорт
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	ВладелецФормы.СохраняемыеСостояния_Сохранить("ДоляОтображенияТяжелых", ДоляОтображенияТяжелых);
	ВладелецФормы.СохраняемыеСостояния_Сохранить("ОтображатьВТерминах1С", ОтображатьВТерминах1С);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПлан()
	
	ПланТекстовый.Очистить();
	План.ПолучитьЭлементы().Очистить();
	
	ПланПрочитан = ПолучитьПланЗапросаИзЖурнала();
	
КонецПроцедуры

&НаКлиенте
Процедура Команда_Обновить(Команда)
	
	соСостояние = ПолучитьСостояниеДерева();
	
	ОбновитьПлан();
	
	Если НЕ ПланПрочитан Тогда
		ПоказатьПредупреждение(, "Не удалось получить информацию о запросе", , Объект.Заголовок);
	Иначе
		РазвернутьПоСостояниюДерево(соСостояние);
	КонецЕсли;
	                     
КонецПроцедуры

&НаКлиенте
Процедура Команда_РазвернутьВсе(Команда)
	Для Каждого ЭлементДерева Из План.ПолучитьЭлементы() Цикл
		Элементы.План.Развернуть(ЭлементДерева.ПолучитьИдентификатор(), Истина);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура Команда_СвернутьВсе(Команда)
	Для Каждого ЭлементДерева Из План.ПолучитьЭлементы() Цикл
		Элементы.План.Свернуть(ЭлементДерева.ПолучитьИдентификатор());
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьПоСостояниюДерево(соСостояние, Путь = "", Узел = Неопределено)
	
	Если Узел = Неопределено Тогда
		Узел = План;
	КонецЕсли;
	
	Для Каждого ЭлементДерева Из Узел.ПолучитьЭлементы() Цикл
		
		ПутьУзла = Путь + "/" + ЭлементДерева.ИсходныйОператор;
		РазвернутьПоСостояниюДерево(соСостояние, ПутьУзла, ЭлементДерева);		
		
		Развернут = соСостояние[ПутьУзла];
		
		Если Развернут <> Неопределено Тогда
			Если Развернут Тогда
				Элементы.План.Развернуть(ЭлементДерева.ПолучитьИдентификатор(), Ложь);
			Иначе
				Элементы.План.Свернуть(ЭлементДерева.ПолучитьИдентификатор());
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСостояниеДерева(Путь = "", Узел = Неопределено, соСостояние = Неопределено)
	
	Если Узел = Неопределено Тогда
		Узел = План;
	КонецЕсли;
	
	Если соСостояние = Неопределено Тогда
		соСостояние = Новый Соответствие;
	КонецЕсли;
	
	Для Каждого ЭлементДерева Из Узел.ПолучитьЭлементы() Цикл
		ПутьУзла = Путь + "/" + ЭлементДерева.ИсходныйОператор;
		соСостояние[ПутьУзла] = Элементы.План.Развернут(ЭлементДерева.ПолучитьИдентификатор());
		соСостояние = ПолучитьСостояниеДерева(ПутьУзла, ЭлементДерева, соСостояние);
	КонецЦикла;
	
	Возврат соСостояние;
	
КонецФункции


