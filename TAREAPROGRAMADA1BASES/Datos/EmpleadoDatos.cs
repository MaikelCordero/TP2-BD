using TAREAPROGRAMADA1BASES.Models;
using System.Data.SqlClient;
using System.Data;
 


namespace TAREAPROGRAMADA1BASES.Datos
{
    public class EmpleadoDatos
    {
        public List<EmpleadoModel> Listar() {

            var oLista =new List<EmpleadoModel>();

            var cn = new Conexion();

            using (var conexion = new SqlConnection(cn.getCadenaSQL())) { 
                conexion.Open();
                SqlCommand cmd = new SqlCommand("sp_listarr",conexion);
                cmd.CommandType = CommandType.StoredProcedure;
                using (var dr = cmd.ExecuteReader()) {
                    while (dr.Read()) {
                        oLista.Add(new EmpleadoModel() { 
                            Id = Convert.ToInt32(dr["id"]),
                            Nombre = dr["Nombre"].ToString(),
                            IDENTIDAD = dr["IDENTIDAD"].ToString(),
                            IdPuesto = dr["IdPuesto"].ToString(),
                        });
                    }
                }
            }
            return oLista;
        }

        public EmpleadoModel Obtener(int Id)
        {

            var oEmpleado = new EmpleadoModel();

            var cn = new Conexion();

            using (var conexion = new SqlConnection(cn.getCadenaSQL()))
            {
                conexion.Open();
                SqlCommand cmd = new SqlCommand("sp_Obtenerr", conexion);
                cmd.Parameters.AddWithValue("Id", Id);
                cmd.CommandType = CommandType.StoredProcedure;
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        oEmpleado.Id = Convert.ToInt32(dr["Id"]);
                        oEmpleado.Nombre = dr["Nombre"].ToString();
                        oEmpleado.IDENTIDAD = dr["IDENTIDAD"].ToString();
                        oEmpleado.IdPuesto = dr["IdPuesto"].ToString();

                    }
                }
            }
            return oEmpleado;
        }

        public bool Guardar(EmpleadoModel oempleado)
        {
            bool rpta;

            try
            {
                var cn = new Conexion();

                using (var conexion = new SqlConnection(cn.getCadenaSQL()))
                {
                    conexion.Open();
                    SqlCommand cmd = new SqlCommand("sp_Guardarr", conexion);
                    cmd.Parameters.AddWithValue("@Nombre", oempleado.Nombre);
                    cmd.Parameters.AddWithValue("@IDENTIDAD", oempleado.IDENTIDAD);
                    cmd.Parameters.AddWithValue("@IdPuesto", oempleado.IdPuesto);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.ExecuteNonQuery();
                }
                rpta = true;
            }
            catch (Exception ex)
            {
                string error = ex.Message;
                rpta = false;
            }

            return rpta;
        }

        public bool Editar(EmpleadoModel oempleado)
        {
            bool rpta;

            try
            {

                var cn = new Conexion();

                using (var conexion = new SqlConnection(cn.getCadenaSQL()))
                {
                    conexion.Open();
                    SqlCommand cmd = new SqlCommand("sp_Editarr", conexion);
                    cmd.Parameters.AddWithValue("id", oempleado.Id);
                    cmd.Parameters.AddWithValue("Nombre", oempleado.Nombre);
                    cmd.Parameters.AddWithValue("IDENTIDAD", oempleado.IDENTIDAD);
                    cmd.Parameters.AddWithValue("IdPuesto", oempleado.IdPuesto);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.ExecuteNonQuery();
                }
                rpta = true;


            }
            catch (Exception ex)
            {

                string error = ex.Message;
                rpta = false;

            }

            return rpta;

        }

        public bool Eliminar(int id)
        {
            bool rpta;

            try
            {

                var cn = new Conexion();

                using (var conexion = new SqlConnection(cn.getCadenaSQL()))
                {
                    conexion.Open();
                    SqlCommand cmd = new SqlCommand("sp_Eliminarr", conexion);
                    cmd.Parameters.AddWithValue("id", id);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.ExecuteNonQuery();
                }
                rpta = true;


            }
            catch (Exception ex)
            {

                string error = ex.Message;
                rpta = false;

            }

            return rpta;

        }
        // Método para verificar si ya existe un nombre registrado
        public bool ExisteNombre(string nombre)
        {
            var cn = new Conexion();
            using (var connection = new SqlConnection(cn.getCadenaSQL()))
            {
                string query = "SELECT COUNT(1) FROM dbo.Empleadoo WHERE Nombre = @Nombre";
                SqlCommand command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@Nombre", nombre);
                connection.Open();
                int count = (int)command.ExecuteScalar();
                return count > 0;
            }
        }

        // Método para verificar si ya existe una identidad registrada
        public bool ExisteIdentidad(string identidad)
        {
            var cn = new Conexion();
            using (var connection = new SqlConnection(cn.getCadenaSQL()))
            {
                string query = "SELECT COUNT(1) FROM dbo.Empleadoo WHERE IDENTIDAD = @Identidad";
                SqlCommand command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@Identidad", identidad);
                connection.Open();
                int count = (int)command.ExecuteScalar();
                return count > 0;
            }
        }

    }
}
