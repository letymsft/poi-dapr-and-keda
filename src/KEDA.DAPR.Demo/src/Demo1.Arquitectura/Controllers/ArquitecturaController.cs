using Dapr;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using System;
using Demo1.Contracts;
using Newtonsoft.Json;

namespace Demo1.Arquitectura.Controllers
{
    [ApiController]
    [Route("api/arquitectura")]
    public class ArquitecturaController : ControllerBase
    {
        private readonly ILogger<ArquitecturaController> _logger;

        private IConfiguration Configuration { get; }

        public ArquitecturaController(IConfiguration configuration, ILogger<ArquitecturaController> logger)
        {
            Configuration = configuration;
            _logger = logger;
        }

        [Topic("pubsub-sandbox-servicebus", "arquitecturapubsub")]
        [HttpPost]
        public async Task<IActionResult> CreateArquitectura([FromBody] string arquitecturaRequest)
        {
            _logger.LogInformation("Inicia creación de arquitectura");
            if (arquitecturaRequest is not null)
            {
                _logger.LogInformation("Arquitectura a crear: {}", arquitecturaRequest);
                ArquitecturaRequest arquitectura = JsonConvert.DeserializeObject<ArquitecturaRequest>(arquitecturaRequest);

                await Task.Delay(TimeSpan.FromSeconds(2));

                _logger.LogInformation("Arquitectura creada: {}", arquitectura.IniciativaId);
                return Ok();
            }
            return BadRequest();
        }
    }
}
