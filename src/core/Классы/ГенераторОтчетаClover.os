#Использовать asserts
#Использовать fs
#Использовать json

Перем ТекущаяЗаписьXML;
Перем ДатаГенерации;
Перем ИмяПроекта;
Перем ПутьКИсходникам;

Процедура СоздатьОтчетClover(Знач ПутьКСтат, Знач ПутьКОтчетуClover) Экспорт
	
	Файл_Стат = Новый Файл(ПутьКСтат);
	Ожидаем.Что(Файл_Стат.Существует(), СтрШаблон("Файл <%1> с результатами покрытия не существует!", Файл_Стат.ПолноеИмя)).ЭтоИстина();
	
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКСтат, КодировкаТекста.UTF8);
	
	СтрокаJSON = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	Парсер = Новый ПарсерJSON();
	ДанныеПокрытия = Парсер.ПрочитатьJSON(СтрокаJSON);

	ТекущаяЗаписьXML = Новый ЗаписьXML;
	ТекущаяЗаписьXML.ОткрытьФайл(ПутьКОтчетуClover);
	ТекущаяЗаписьXML.ЗаписатьОбъявлениеXML();
	
	ДатаГенерации = ДатуВTimestamp(ТекущаяДата());

	ТекущаяЗаписьXML.ЗаписатьНачалоЭлемента("coverage");
	ТекущаяЗаписьXML.ЗаписатьАтрибут("clover", "1.0");
	ТекущаяЗаписьXML.ЗаписатьАтрибут("generated", ДатаГенерации);
	
	ТаблицаМетрик = ПолучитьТаблицуМетрик();
	
	ДобавитьОписаниеПроекта(ИмяПроекта);
	ДобавитьОписаниеПакета("main");

	ВсегоФайловВПакете = 0;
	МетрикаПакета = Новый Структура;

	Для Каждого Файл Из ДанныеПокрытия Цикл

		ДанныеФайла = Файл.Значение;

		ПутьКФайлу = ДанныеФайла.Получить("#path");

		Если НЕ ФайлПодлежитПроверке(ПутьКФайлу) Тогда
			Продолжить;
		КонецЕсли;

		ВсегоФайловВПакете = ВсегоФайловВПакете + 1;

		ФайлПокрытия = Новый Файл(ПутьКФайлу);
		ИмяФайла = ФайлПокрытия.Имя;
		
		ТекущаяЗаписьXML.ЗаписатьНачалоЭлемента("file");
		ТекущаяЗаписьXML.ЗаписатьАтрибут("name", ИмяФайла);
		ТекущаяЗаписьXML.ЗаписатьАтрибут("path", ПутьКФайлу);
		
		КоличествоМетодов = 0;
		КоличествоПокрытыхМетодов = 0;
		ОбщееВремяВыполнения = 0;
		ВсегоСтрокВФайле = 0;
		ВсегоЭлементов = 0;
		ВсегоПокрытоЭлементов = 0;
				
		Для Каждого КлючИЗначение Из ДанныеФайла Цикл
			
			ИмяМетода = КлючИЗначение.Ключ;
			
			Если ИмяМетода = "#path" Тогда
				Продолжить;
			КонецЕсли;
			
			КоличествоМетодов = КоличествоМетодов + 1;

			ПокрытыхСтрокВМетоде = 0;

			ДанныеПроцедуры = КлючИЗначение.Значение;
			ВсегоЭлементовМетода = 0;
			ЗаписатьМетод = Не ИмяМетода = "$entry";

			Для Каждого ДанныеСтроки Из ДанныеПроцедуры Цикл
				
				ТипСтроки = "stmt";
				Если ЗаписатьМетод Тогда
					ТипСтроки = "method";
					ЗаписатьМетод = Ложь;
				КонецЕсли;

				ТекущаяЗаписьXML.ЗаписатьНачалоЭлемента("line");
				
				ТекущаяЗаписьXML.ЗаписатьАтрибут("num", ДанныеСтроки.Ключ);
				ТекущаяЗаписьXML.ЗаписатьАтрибут("type", ТипСтроки);
				
				Покрыто = Число(ДанныеСтроки.Значение.Получить("count")) > 0;
				ТекущаяЗаписьXML.ЗаписатьАтрибут("count", ДанныеСтроки.Значение.Получить("count"));
				
				ТекущаяЗаписьXML.ЗаписатьКонецЭлемента(); // lineToCover
			
				Если Покрыто Тогда
					ПокрытыхСтрокВМетоде = ПокрытыхСтрокВМетоде + 1;
				КонецЕсли;

				ВсегоЭлементовМетода = ВсегоЭлементовМетода + 1;

				ОбщееВремяВыполнения = ОбщееВремяВыполнения + ДанныеСтроки.Значение.Получить("time");

				ВсегоСтрокВФайле = Макс(ВсегоСтрокВФайле, Число(ДанныеСтроки.Ключ));

			КонецЦикла;

			МетодПокрытПолностью = ДанныеПроцедуры.Количество() = ПокрытыхСтрокВМетоде;

			Если МетодПокрытПолностью Тогда
				КоличествоПокрытыхМетодов = КоличествоПокрытыхМетодов + 1;
			КонецЕсли;

			ВсегоЭлементов = ВсегоЭлементов + ВсегоЭлементовМетода;
		
			ВсегоПокрытоЭлементов = ВсегоПокрытоЭлементов + ПокрытыхСтрокВМетоде;

		КонецЦикла;
	
		ИмяКласса = ФайлПокрытия.ИмяБезРасширения;
		ТекущаяЗаписьXML.ЗаписатьНачалоЭлемента("class");
		ТекущаяЗаписьXML.ЗаписатьАтрибут("name", ИмяКласса);
		МетрикаКласса = ПодготовитьМетрикиКласса(ВсегоЭлементов, 
												ВсегоПокрытоЭлементов,
												КоличествоМетодов,
												КоличествоПокрытыхМетодов,
												ОбщееВремяВыполнения);
		ЗаписатьЭлементXML("metrics", МетрикаКласса);
		ТекущаяЗаписьXML.ЗаписатьКонецЭлемента(); // file
		
		ПолучитьМетрикуФайла(ВсегоСтрокВФайле, МетрикаКласса);

		ЗаписатьЭлементXML("metrics", МетрикаКласса);
		ТекущаяЗаписьXML.ЗаписатьКонецЭлемента(); // file
		
		ДобавитьМетрикуВМетрикуПакета(МетрикаПакета, МетрикаКласса);

	КонецЦикла;

	МетрикаПакета.Вставить("files", ВсегоФайловВПакете);
	ЗаписатьЭлементXML("metrics", МетрикаПакета);
	
	ТекущаяЗаписьXML.ЗаписатьКонецЭлемента(); // Пакеи
	
	МетрикаПакета.Вставить("packages", 1);
	ЗаписатьЭлементXML("metrics", МетрикаПакета);
	
	ТекущаяЗаписьXML.ЗаписатьКонецЭлемента(); // Проект

	ТекущаяЗаписьXML.ЗаписатьКонецЭлемента(); // coverage
	
	ТекущаяЗаписьXML.Закрыть();

КонецПроцедуры

Процедура ЗаписатьЭлементXML(ИмяЭлемента, Атрибуты)
	
	ДобавитьЭлементXML(ИмяЭлемента, Атрибуты);

	ТекущаяЗаписьXML.ЗаписатьКонецЭлемента(); // coverage

КонецПроцедуры

Функция ФайлПодлежитПроверке(ПутьКФайлу)

	ФайлПодходит = СтрНачинаетсяС(ПутьКФайлу, ПутьКИсходникам);

	Возврат ФайлПодходит;

КонецФункции

Функция ПолучитьМетрикуФайла(ВсегоСтрокКода, МетрикаКласса)
	
	МетрикаКласса.Вставить("classes", 1);
	МетрикаКласса.Вставить("loc", ВсегоСтрокКода);
	МетрикаКласса.Вставить("ncloc", ВсегоСтрокКода - МетрикаКласса.elements);

	Возврат МетрикаКласса;

КонецФункции

Процедура ДобавитьМетрикуВМетрикуПакета(МетрикаПакета, МетрикаКласса)

	Для каждого КлючИЗначение Из МетрикаКласса Цикл
		
		ЗначениеМетрикиПакета = Неопределено;

		Если Не МетрикаПакета.Свойство(КлючИЗначение.Ключ, ЗначениеМетрикиПакета) Тогда
			МетрикаПакета.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
		Иначе
			МетрикаПакета.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение + ЗначениеМетрикиПакета);
		КонецЕсли;

	КонецЦикла;
	
КонецПроцедуры

Функция ПодготовитьМетрикиКласса(ВсегоЭлементов, ВсегоПокрытоЭлементов,
							ВсегоМетодов, ВсегоПокрытоМетодов,
							ВремяВыполнения)

	Метрики = Новый Структура();

	// Обязательные атрибуты 

	Метрики.Вставить("complexity", 0); // Не считает Oscript 
	Метрики.Вставить("elements", ВсегоЭлементов); 
	Метрики.Вставить("coveradelements", ВсегоПокрытоЭлементов); 
	Метрики.Вставить("conditionals", 0); // Не считает Oscript
	Метрики.Вставить("coveredconditionals", 0); // Не считает Oscript

	Метрики.Вставить("statements", ВсегоЭлементов); 
	Метрики.Вставить("coveredstatements", ВсегоПокрытоЭлементов); 
	
	Метрики.Вставить("methods", ВсегоМетодов); 
	Метрики.Вставить("coveredmethods", ВсегоПокрытоМетодов); 

	Метрики.Вставить("testduration", ВремяВыполнения); 

	Возврат Метрики;

КонецФункции

Функция КолонкиМетрик()

	Возврат СтрРазделить("complexity,elements,coveradelements,conditionals,coveredconditionals,statements,coveredstatements,methods,coveredmethods,testduration", ",", Ложь);
	
КонецФункции

Функция ПолучитьТаблицуМетрик()
	
	ТаблицаМетрик = Новый ТаблицаЗначений;
	
	МассивМетрик = КолонкиМетрик();
	
	Для каждого Метрика Из МассивМетрик Цикл
		ТаблицаМетрик.Колонки.Добавить(Метрика);
	КонецЦикла;

	Возврат ТаблицаМетрик;

КонецФункции

Функция СформироватьМетрикиПоТаблице(ТаблицаМетрикКлассов, ПоляГруппировок = "")

	ТаблицаВозврата = ТаблицаМетрикКлассов.Скопировать();

	МассивМетрик = КолонкиМетрик();
	СтрокаСуммирования = СтрСоединить(МассивМетрик, ",");

	ТаблицаВозврата.Свернуть(ПоляГруппировок, СтрокаСуммирования);

	Возврат ТаблицаВозврата;

КонецФункции

Процедура ДобавитьЭлементXML(ИмяЭлемента, АтрибутыЭлемента)
	
	ТекущаяЗаписьXML.ЗаписатьНачалоЭлемента(ИмяЭлемента);

	Для каждого АтрибутЭлемента Из АтрибутыЭлемента Цикл
		ТекущаяЗаписьXML.ЗаписатьАтрибут(АтрибутЭлемента.Ключ, АтрибутЭлемента.Значение);
	КонецЦикла;
		
КонецПроцедуры

Процедура ДобавитьОписаниеПроекта(ИмяПроекта)
	
	Атрибуты = Новый Структура("name, timestamp", ИмяПроекта, ДатаГенерации);

	ДобавитьЭлементXML("project", Атрибуты);

КонецПроцедуры

Процедура ДобавитьОписаниеПакета(ИмяПакета, КоличесnвоФайлов = 0)
	
	Атрибуты = Новый Структура("name", ИмяПакета);

	ДобавитьЭлементXML("package", Атрибуты);

	// Если КоличесnвоФайлов > 0 Тогда
		
	// КонецЕсли;

КонецПроцедуры

Процедура ПриСозданииОбъекта(Знач КаталогИсходников, Знач ВходящееИмяПроекта)
	ПутьКИсходникам = Новый Файл(КаталогИсходников).ПолноеИмя;
	ИмяПроекта = ВходящееИмяПроекта;
КонецПроцедуры

Функция ДатуВTimestamp(пДата = Неопределено)
	Возврат Формат(Число(?(ТипЗнч(пДата) = Тип("Дата"), пДата, ТекущаяДата())-Дата("19700101")),"ЧН=0; ЧГ=0");
 КонецФункции