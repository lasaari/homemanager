local status_ok, zenburn = pcall(require, "zenburn")
if not status_ok then
  return
end
zenburn.setup()
