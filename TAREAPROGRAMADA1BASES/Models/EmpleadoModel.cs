using System.ComponentModel.DataAnnotations;

namespace TAREAPROGRAMADA1BASES.Models
{
    public class EmpleadoModel
    {
        [Required(ErrorMessage ="El id es requerido")]
        public int id { get; set; }

        [Required(ErrorMessage ="El nombre es requerido para guardar el empleado")]
        public string? Nombre { get; set; }
        
        [Required(ErrorMessage ="El salario es requerido para guardar el empleado")]
        public string? Salario { get; set; }
    }
}
