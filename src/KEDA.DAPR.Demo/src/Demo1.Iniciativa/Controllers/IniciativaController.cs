using Dapr.Client;
using Demo1.Contracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Threading.Tasks;

namespace Demo1.Iniciativa.Controllers
{
    [Route("api/iniciativa")]
    [ApiController]
    public class IniciativaController : ControllerBase
    {
        private readonly ILogger<IniciativaController> _logger;

        public IniciativaController(ILogger<IniciativaController> logger)
        {
            _logger = logger;
        }

        [HttpPost("createiniciativa")]
        public async Task<IActionResult> CreateIniciativa([FromBody] IniciativaRequest iniciativa)
        {
            _logger.LogInformation("Inicia creación de iniciativa");
            if (iniciativa is not null && iniciativa.Arquitectura is not null && iniciativa.Presupuesto is not null)
            {
                iniciativa.IniciativaId = Guid.NewGuid().ToString();
                _logger.LogInformation("Iniciativa a crear: {}", JsonConvert.SerializeObject(iniciativa));

                ArquitecturaRequest arquitectura = iniciativa.Arquitectura;
                arquitectura.IniciativaId = iniciativa.IniciativaId;
                string arquitecturaJson = JsonConvert.SerializeObject(arquitectura);
                _logger.LogInformation("Arquitectura a publicar: {}", arquitecturaJson);

                PresupuestoRequest presupuesto = iniciativa.Presupuesto;
                presupuesto.IniciativaId = iniciativa.IniciativaId;
                string presupuestoJson = JsonConvert.SerializeObject(presupuesto);
                _logger.LogInformation("Presupuesto a publicar: {}", presupuestoJson);

                using var client = new DaprClientBuilder().Build();
                
                await client.PublishEventAsync("pubsub-sandbox-servicebus", "arquitecturapubsub", arquitecturaJson);
                _logger.LogInformation("Arquitectura publicada");
                
                await client.PublishEventAsync("pubsub-sandbox-servicebus", "presupuestopubsub", presupuestoJson);
                _logger.LogInformation("Presupuesto publicado");

                return Ok();
            }
            return BadRequest();
        }
    }
}
