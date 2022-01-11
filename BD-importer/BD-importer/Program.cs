/*
1. Требования к приложению загрузки данных(из файла в БД)
1)	Приложение должно загружать в базу данных из входного текстового файла
(который может содержать текст на английском и русском языках, в кодировке UTF-8) все слова, удовлетворяющие следующим критериям:
a)	длина слова не менее 3 и не более 20 символов;
b)	слово упоминается в текущем входном файле не менее 4-ёх раз.
2) Загрузка может выполняться многократно.При этом приложение не должно удалять существующие данные из базы данных, а должно дополнять их.
3) В базе данных для каждого сохранённого слова должно храниться количество его упоминаний, 
суммарное для всех загруженных файлов(т.е.в результате загрузки каждого нового файла существующее в базе данных количество упоминаний 
должно быть увеличено на количество упоминаний в новом файле).
4)	Текстовый файл, подаваемый на вход, должен быть в кодировке UTF-8. Файл может содержать любые буквы(латиница и кириллица) и пробелы.
Файл может содержать более одной строки.Файл может иметь размер до 100 МБ.
5) Приложение должно корректно обновлять информацию в базе данных в случае, если одновременно выполняется несколько копий этого приложения,
работающих с одной и той же базой данных.
6)	Приложение должно автоматически создавать и инициализировать базу данных(включая её таблицы и т.д.) в случае, если таковая отсутствует;
либо должен быть предоставлен SQL-скрипт для её первичного создания.
7)	База данных должна быть реализована с использованием MS SQL Server / SQL Server Express.
*/

using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Threading.Tasks;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;//.Regex;


namespace BD_importer
{
    class Program
    {
        const string connectionString = "Data Source=WIN-SLHNLIKR0SF;Initial Catalog=text;Integrated Security=True; trust server certificate=True";
        const string path = "input.txt";
        static void Read(ref Dictionary <string, int> vacabulary)
        {
            string line;
            Console.WriteLine("считывание данных");
            using (StreamReader sr = new StreamReader(path, System.Text.Encoding.UTF8))
            {
                while ((line = sr.ReadLine()) != null)
                {
                    string pattern = @"(?:[а-яА-Я]{3,20})|(?:[a-zA-Z]{3,20})";
                    Regex regex = new Regex(pattern);

                    // Получаем совпадения в экземпляре класса Match
                    Match match = regex.Match(line.ToLower());

                    // отображаем все совпадения
                    while (match.Success)
                    {
                        // Т.к. мы выделили в шаблоне одну группу (одни круглые скобки),
                        // ссылаемся на найденное значение через свойство Groups класса Match
                        string word = match.Groups[0].Value;

                        if (vacabulary.ContainsKey(word))
                        {
                            vacabulary[word]++;
                        }
                        else
                        {
                            vacabulary.Add(word, 1);
                        }
                        // Переходим к следующему совпадению
                        match = match.NextMatch();
                    }
                }
            }
            Console.WriteLine("считывание данных завершено. в словарь добавлено " + vacabulary.Count + " слов");
        }
        static void Mutate(ref Dictionary <string, int> vacabulary)
        {
            Console.WriteLine("обработка данных");
            foreach(KeyValuePair <string, int> word in vacabulary)
            {
                if (word.Value < 4)
                {
                    vacabulary.Remove(word.Key);
                }
            }
            Console.WriteLine("обработка данных завершена. в словаре осталось " + vacabulary.Count + " слов");
        }
        static void Import(Dictionary<string, int> vacabulary)
        {
            //string connectionString = "Server=(localdb)\\mssqllocaldb;Database=master;Trusted_Connection=True;";
            // Создание подключения
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                Console.WriteLine("Подключение открыто");
                AddWords(connection, vacabulary);
            }
            catch (SqlException ex)
            {

                Console.WriteLine(ex.Message);
            }
            finally
            {
                // если подключение открыто
                if (connection.State == ConnectionState.Open)
                {
                    Console.WriteLine("слова переданы в базу");
                    // закрываем подключение
                    connection.Close();
                    Console.WriteLine("Подключение закрыто");
                }
            }
        }

        static void AddWords(SqlConnection connection, Dictionary<string, int> vacabulary)
        {
            // название процедуры
            string sqlExpression = "AddWords";

            connection.Open();
            foreach (KeyValuePair<string, int> pair in vacabulary)
            {
                SqlCommand command = new SqlCommand(sqlExpression, connection);
                //указываем, что команда представляет хранимую процедуру
                command.CommandType = System.Data.CommandType.StoredProcedure;
                SqlParameter keyParam = new SqlParameter
                {
                    ParameterName = "@word",
                    Value = pair.Key
                };
                command.Parameters.Add(keyParam);
                SqlParameter valParam = new SqlParameter
                {
                    ParameterName = "@word_count",
                    Value = pair.Value
                };
                command.Parameters.Add(valParam);
                var result = command.ExecuteNonQuery();
            }
        }


        static void Main(string[] args)
        {
            Dictionary<string, int> vacabulary = new Dictionary<string, int>();
            Read(ref vacabulary);
            Mutate(ref vacabulary);
            Import(vacabulary);
            Console.ReadKey();
        }
    }
}
