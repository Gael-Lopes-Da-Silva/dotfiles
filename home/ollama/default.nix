{ ... }:

{
  services.ollama = {
    enable = true;
    port = 11434;
    host = "127.0.0.1";
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "4";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_KEEP_ALIVE = "10m";
    };
  };
}
