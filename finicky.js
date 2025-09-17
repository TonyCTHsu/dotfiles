export default {
  defaultBrowser: {
    name: "Google Chrome",
    profile: "Tony"
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
