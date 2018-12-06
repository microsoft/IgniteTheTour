using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Text;
using lp3s3.CommentCogSvc.Database;

namespace lp3s3.CommentCogSvc.CogSvc
{
    public class TextAnalyser
    {
        private readonly string analyticsSubscriptionKey;
        private readonly string translatorSubscriptionKey;
        private readonly string region;
        private HttpClient client;

        public TextAnalyser(string analyticsSubscriptionKey, string translatorSubscriptionKey, string region = "westus")
        {
            this.analyticsSubscriptionKey = analyticsSubscriptionKey;
            this.translatorSubscriptionKey = translatorSubscriptionKey;
            this.region = region;
            client = new HttpClient()
            {
                BaseAddress = new Uri($"https://{region}.api.cognitive.microsoft.com")
            };
            client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json")
            );
            client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", analyticsSubscriptionKey);
        }

        public CommentAnalysis GetTextAnalysis(int id, string comment)
        {
            // 1. Get Language
            var lang = "en";
            var byteData = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(new
            {
                documents = new[] {
                    new {id= 1, text = comment}
                }
            }));

            using (var content = new ByteArrayContent(byteData))
            {
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                var response = client.PostAsync("text/analytics/v2.0/languages", content).Result;
                var result = response.Content.ReadAsStringAsync().Result;
                var jobject = JObject.Parse(result);
                lang = (string)(jobject["documents"][0]["detectedLanguages"][0]["iso6391Name"]);
                lang = VerifyIetfStandard(lang);
            }

            // 2. Get Sentiment
            int sentiment = 0;
            byteData = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(new
            {
                documents = new[] {
                    new {id= 1, text = comment, language = lang}
                }
            }));

            using (var content = new ByteArrayContent(byteData))
            {
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                var response = client.PostAsync("text/analytics/v2.0/sentiment", content).Result;
                var result = response.Content.ReadAsStringAsync().Result;
                var jobject = JObject.Parse(result);
                sentiment = (int)((decimal)(jobject["documents"][0]["score"]) * 100);
            }

            // 3. Get Keywords
            var keywords = "";
            byteData = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(new
            {
                documents = new[] {
                    new {id= 1, text = comment, language = lang}
                }
            }));

            using (var content = new ByteArrayContent(byteData))
            {
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                var response = client.PostAsync("text/analytics/v2.0/keyPhrases", content).Result;
                var result = response.Content.ReadAsStringAsync().Result;
                var jobject = JObject.Parse(result);
                if (((JArray)jobject["errors"]).Count > 0)
                {
                    var err = (string)(jobject["errors"][0]["message"]);
                    keywords = err.Substring(0, err.IndexOf("."));
                }
                else
                {
                    keywords = string.Join(",", (jobject["documents"][0]["keyPhrases"]).ToObject<IEnumerable<string>>());
                }
            }

            // 4. Translate if not English
            var translation = "";
            if (lang != "en")
            {
                var translationClient = new HttpClient();

                var stringData = JsonConvert.SerializeObject(new[] {
                    new {Text = comment}
                });

                using (var content = new ByteArrayContent(byteData))
                {
                    using (var request = new HttpRequestMessage())
                    {
                        request.Method = HttpMethod.Post;
                        request.RequestUri = new Uri($"https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from={lang}&to=en");
                        request.Content = new StringContent(stringData, Encoding.UTF8, "application/json");
                        request.Headers.Add("Ocp-Apim-Subscription-Key", translatorSubscriptionKey);
                        content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                        var response = translationClient.SendAsync(request).Result;
                        var result = response.Content.ReadAsStringAsync().Result;
                        if (result.StartsWith("{\"error"))
                        {
                            var jobject = JObject.Parse(result);
                            translation = $"unable to translate text - {jobject["error"]["message"]}";
                        }
                        else
                        {
                            var jarray = JArray.Parse(result);
                            translation = (string)(jarray[0]["translations"][0]["text"]);
                        }
                    }
                }
            }

            return new CommentAnalysis()
            {
                Id = id,
                Sentiment = sentiment,
                Language = lang,
                EnglishTranslation = translation,
                Keywords = keywords
            };
        }

        private string VerifyIetfStandard(string lang)
        {
            // chinese language code correction:
            switch (lang.ToLower())
            {
                case "zh_chs":
                    return "zh-Hans";
                case "zh_cht":
                    return "zh-Hant";
                default:
                    return lang;
            }
        }
    }
}