using System.Data.SqlClient;

namespace TAREAPROGRAMADA1BASES.Datos
{
    public class Conexion
    {
        private string cadenaSQL= string.Empty;
        public Conexion(){
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json").Build();
            //var es una variable que permite crear cualquier tipo de variable

            cadenaSQL = builder.GetSection("ConnectionStrings:CadenaSQL").Value;


        }

        public string getCadenaSQL()
        {

        return cadenaSQL; 
        }

    }
}
