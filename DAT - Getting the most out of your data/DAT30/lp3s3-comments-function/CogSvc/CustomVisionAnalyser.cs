using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using System.Text;

using Microsoft.Azure.CognitiveServices.Vision.CustomVision.Prediction;
using Microsoft.Azure.CognitiveServices.Vision.CustomVision.Prediction.Models;

namespace lp3s3.CommentCogSvc.CogSvc
{
    public class CustomVisionAnalyser
    {
        private readonly string customVisionSubscriptionKey;
        private readonly Guid customVisionProjectId;

        public CustomVisionAnalyser(string customVisionSubscriptionKey, Guid customVisionProjectId)
        {
            this.customVisionSubscriptionKey = customVisionSubscriptionKey;
            this.customVisionProjectId = customVisionProjectId;
        }

        public IEnumerable<TagPrediction> GetImageTagPredictions(string imageUrl)
        {
            var client = new CustomVisionPredictionClient() 
            {
                ApiKey = customVisionSubscriptionKey,
                Endpoint = "https://southcentralus.api.cognitive.microsoft.com"
            };

            var result = client.PredictImageUrl(customVisionProjectId, new ImageUrl(imageUrl));

            return result.Predictions.Select(p => new TagPrediction(p.TagName, (int)(p.Probability*100))).ToList();
        }
    }

    public class TagPrediction
    {
        public TagPrediction(string tagName, int tagProbability)
        {
            this.Tag = tagName;
            this.Confidence = tagProbability;
        }
        public string Tag { get; set; }
        public int Confidence { get; set; }
    }
}