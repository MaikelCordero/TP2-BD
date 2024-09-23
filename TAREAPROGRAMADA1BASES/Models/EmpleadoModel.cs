using System.ComponentModel.DataAnnotations;

namespace TAREAPROGRAMADA1BASES.Models
{
    public class EmpleadoModel
    {
        [Required(ErrorMessage ="El id es requerido")]
        public int id { get; set; }

        [Required(ErrorMessage = "La identidad o cédula es requerida para guardar el empleado")]
        [RegularExpression("^[0-9]*$", ErrorMessage = "El documento de identidad solo debe contener números")]
        public string? IDENTIDAD { get; set; }
        
        [Required(ErrorMessage ="El nombre es requerido para guardar el empleado")]
        public string? Nombre { get; set; }

        [Required(ErrorMessage = "El idPuesto es requerido para guardar el empleado")]
        public string? IdPuesto { get; set; }


    }
}
