/*
1)	Приложение должно принимать в виде входного параметра строку (содержащую слово или его часть)
и выводить в консоль те слова из базы данных, которые начинаются с указанной строки и при этом имеют наибольшее количество упоминаний в базе данных.

2)	Выводимые слова должны быть отсортированы в порядке убывания количества их упоминаний в базе данных.
В случае совпадения количества упоминаний у разных слов таковые должны отсортированы по алфавиту.

3)	Должно быть выведено не более 5 слов, удовлетворяющих вышеописанным критериям.

4)	При выводе в консоль слова должны быть разделены переводом строки.
*/


using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.IO;


namespace BD_exporter
{
    class Program
    {
        const string connectionString = "Data Source=WIN-SLHNLIKR0SF;Initial Catalog=text;Integrated Security=True; trust server certificate=True";
 
        static void Export(string search)
        {
            // Создание подключения
            SqlConnection connection = new SqlConnection(connectionString);
            string sqlExpression = "ShowWords";
            try
            {
                search += "%";
                Console.WriteLine("Подключение открыто");
                connection.Open();
                SqlCommand command = new SqlCommand(sqlExpression, connection);
                //указываем, что команда представляет хранимую процедуру
                command.CommandType = System.Data.CommandType.StoredProcedure;
                SqlParameter keyParam = new SqlParameter
                {
                    ParameterName = "@word",
                    Value = search
                };
                command.Parameters.Add(keyParam);
                var result = command.ExecuteReader();
                if (result.HasRows)
                {
                    while(result.Read())
                    {
                        var word = result.GetValue(0);
                        //var wordcount = result.GetValue(1);
                        Console.WriteLine(word); //+ " " + wordcount);
                    }
                }
                Console.WriteLine();
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
                    // закрываем подключение
                    connection.Close();
                    Console.WriteLine("Подключение закрыто");
                }
            }
        }


        static void Main(string[] args)
        {
            Console.WriteLine("введите слово или его часть");
            string search = Console.ReadLine();
            Export(search);
            Console.ReadKey();
        }
    }
}