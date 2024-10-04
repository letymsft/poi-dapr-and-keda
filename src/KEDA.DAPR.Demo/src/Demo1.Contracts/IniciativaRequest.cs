namespace Demo1.Contracts
{
    public class IniciativaRequest
    {
        public string? IniciativaId { get; set; }

        public string? NombreIniciativa { get; set; }

        public string? UserId { get; set; }

        public ArquitecturaRequest? Arquitectura { get; set; }

        public PresupuestoRequest? Presupuesto { get; set; }    
    }
}
