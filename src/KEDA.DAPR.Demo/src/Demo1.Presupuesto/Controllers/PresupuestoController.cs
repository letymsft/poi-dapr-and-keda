using Dapr;
using Demo1.Contracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Threading.Tasks;
using Dapr.Client;

namespace Demo1.Presupuesto.Controllers
{
    [ApiController]
    [Route("api/presupuesto")]
    public class PresupuestoController : ControllerBase
    {
        private readonly ILogger<PresupuestoController> _logger;

        private IConfiguration Configuration { get; }

        public PresupuestoController(IConfiguration configuration, ILogger<PresupuestoController> logger)
        {
            Configuration = configuration;
            _logger = logger;
        }

        [Topic("pubsub-sandbox-servicebus", "presupuestopubsub")]
        [HttpPost]
        public async Task<IActionResult> CreatePresupuesto([FromBody] string presupuestoRequest)
        {
            _logger.LogInformation("Inicia creación de presupuesto");
            if (presupuestoRequest is not null)
            {
                _logger.LogInformation("Presupuesto a publicar: {}", presupuestoRequest);
                PresupuestoRequest presupuesto = JsonConvert.DeserializeObject<PresupuestoRequest>(presupuestoRequest);

                using var client = new DaprClientBuilder().Build();

                await client.PublishEventAsync("pubsub-sandbox-servicebus", "ftppubsub", presupuestoRequest);
                _logger.LogInformation("Presupuesto publicado {}", presupuesto.IniciativaId);
                
                return Ok();
            }
            return BadRequest();
        }
    }
}
