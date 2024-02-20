using Microsoft.AspNetCore.Mvc;
using FastReport.Export.PdfSimple;

namespace FastReport.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FilesController : ControllerBase
    {
        [HttpPost("Demo1")]
        public IActionResult Demo1()
        {
            return File(GetReport(), "application/pdf", "demo1.pdf");
        }

        private static byte[] GetReport()
        {
            string filePath = System.IO.Path.Combine(Environment.CurrentDirectory, "Reports", "Demo1.frx");
            Report report = Report.FromFile(filePath);
            report.Prepare();
            

            using MemoryStream ms = new();
            PDFSimpleExport pdfExport = new();
            pdfExport.Export(report, ms);
            ms.Flush();

            return ms.ToArray();
        }
    }
}
