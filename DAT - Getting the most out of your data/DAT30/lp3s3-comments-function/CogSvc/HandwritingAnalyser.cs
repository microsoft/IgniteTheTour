using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using System.Text;

using Microsoft.Azure.CognitiveServices.Vision.ComputerVision;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision.Models;

namespace lp3s3.CommentCogSvc.CogSvc
{
    public class HandwritingAnalyser
    {
        private readonly string analyticsSubscriptionKey;
        private readonly string region;
        private const int numberOfCharsInOperationId = 36;

        public HandwritingAnalyser(string analyticsSubscriptionKey, string region = "westus")
        {
            this.analyticsSubscriptionKey = analyticsSubscriptionKey;
            this.region = region;
        }

        public async Task<string> GetHandwritingAnalysis(string imageUrl)
        {
            var computerVision = new ComputerVisionClient(
                new ApiKeyServiceClientCredentials(analyticsSubscriptionKey),
                new System.Net.Http.DelegatingHandler[] {}
            );

            computerVision.Endpoint = $"https://{region}.api.cognitive.microsoft.com";

            var result = await ExtractRemoteTextAsync(computerVision, imageUrl);
            return result;
        }

        private static async Task<string> ExtractRemoteTextAsync(ComputerVisionClient computerVision, string imageUrl) {
            var textHeaders = await computerVision.RecognizeTextAsync(imageUrl, TextRecognitionMode.Handwritten);
            return await GetTextAsync(computerVision, textHeaders.OperationLocation);
        }

        private static async Task<string> GetTextAsync(ComputerVisionClient computerVision, string operationLocation)
        {
            // Retrieve the URI where the recognized text will be
            // stored from the Operation-Location header
            var operationId = operationLocation.Substring(operationLocation.Length - numberOfCharsInOperationId);

            var result = await computerVision.GetTextOperationResultAsync(operationId);

            // Wait for the operation to complete
            int i = 0;
            int maxRetries = 10;
            while ((result.Status == TextOperationStatusCodes.Running ||
                    result.Status == TextOperationStatusCodes.NotStarted) && i++ < maxRetries)
            {
                await Task.Delay(1000);
                result = await computerVision.GetTextOperationResultAsync(operationId);
            }

            // Return the results
            var lines = result.RecognitionResult.Lines;
            return string.Join(Environment.NewLine, lines.Select(l => l.Text));
        }
    }
}