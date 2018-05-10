#использовать "../src/core"
#Использовать asserts
#Использовать logos
#Использовать tempfiles
#Использовать json

Перем юТест;
Перем Лог;

Функция ПолучитьСписокТестов(Знач Тестирование) Экспорт

	юТест = Тестирование;

	ИменаТестов = Новый Массив;

	ИменаТестов.Добавить("ТестДолжен_ГенерацииОтчетаClover");
	// ИменаТестов.Добавить("ТестДолжен_ПроверитьВыгрузкуПараметровВКласс");
	// ИменаТестов.Добавить("ТестДолжен_ПроверитьПоискИЧтениеФайлаПараметров");
	// ИменаТестов.Добавить("ТестДолжен_ПроверитьПарсингОпций");
	// ИменаТестов.Добавить("ТестДолжен_ПроверитьПарсингМассивовОпций");


	Возврат ИменаТестов;

КонецФункции

Процедура ТестДолжен_ГенерацииОтчетаClover() Экспорт

	РабочаяДиректория = ТекущийСценарий().Каталог;

	ФайлСтатистики = ОбъединитьПути(РабочаяДиректория, "fixtures", "fake-coverage.json");

	ВременныйКаталог = ВременныеФайлы.СоздатьКаталог();

	ФайлПокрытияClover = ОбъединитьПути(ВременныйКаталог, "clover.xml");

	ПроцессорГенерации = Новый ГенераторОтчетаClover(РабочаяДиректория, "Тест");

	ПроцессорГенерации.СоздатьОтчетClover(ФайлСтатистики, ФайлПокрытияClover);

	ВременныеФайлы.УдалитьФайл(ВременныйКаталог);

КонецПроцедуры

Процедура ПодготовитьТестовыеДанные()

	// СистемнаяИнформация = Новый СистемнаяИнформация;
	// ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
	
	// ФС.ОбеспечитьПустойКаталог("coverage");
	// ПутьКСтат = "coverage/stat.json";
	
	// Команда = Новый Команда;
	// Команда.УстановитьКоманду("oscript");
	// Если НЕ ЭтоWindows Тогда
	// 	Команда.ДобавитьПараметр("-encoding=utf-8");
	// КонецЕсли;
	// Команда.ДобавитьПараметр(СтрШаблон("-codestat=%1", ПутьКСтат));    
	// Команда.ДобавитьПараметр("tasks/test.os");
	// Команда.ПоказыватьВыводНемедленно(Истина);
	
	// КодВозврата = Команда.Исполнить()

КонецПроцедуры