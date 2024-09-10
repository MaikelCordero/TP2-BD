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
                SqlCommand cmd = new SqlCommand("sp_listar",conexion);
                cmd.CommandType = CommandType.StoredProcedure;
                using (var dr = cmd.ExecuteReader()) {
                    while (dr.Read()) {
                        oLista.Add(new EmpleadoModel() { 
                            id = Convert.ToInt32(dr["id"]),
                            Nombre = dr["Nombre"].ToString(),
                            Salario = dr["Salario"].ToString(),
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
                SqlCommand cmd = new SqlCommand("sp_Obtener", conexion);
                cmd.Parameters.AddWithValue("id", Id);
                cmd.CommandType = CommandType.StoredProcedure;
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        oEmpleado.id = Convert.ToInt32(dr["id"]);
                        oEmpleado.Nombre = dr["Nombre"].ToString();
                        oEmpleado.Salario = dr["Salario"].ToString();
                        
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
                    SqlCommand cmd = new SqlCommand("sp_Guardar", conexion);
                    cmd.Parameters.AddWithValue("@Nombre", oempleado.Nombre);
                    cmd.Parameters.AddWithValue("@Salario", oempleado.Salario);
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
                    SqlCommand cmd = new SqlCommand("sp_Editar", conexion);
                    cmd.Parameters.AddWithValue("id", oempleado.id);
                    cmd.Parameters.AddWithValue("Nombre", oempleado.Nombre);
                    cmd.Parameters.AddWithValue("Salario", oempleado.Salario);
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
                    SqlCommand cmd = new SqlCommand("sp_Eliminar", conexion);
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

    }
}
