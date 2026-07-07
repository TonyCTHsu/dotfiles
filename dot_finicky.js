export default {
  defaultBrowser: {
    name: "Google Chrome",
    profile: "datadoghq.com"
  },
  handlers: [
    {
      match: /datadog/i,
      browser: {
        name: "Google Chrome",
        profile: "datadoghq.com"
      }
    }
  ],
};
