def name(vars):
  return kube_clean_name(vars.chart.name or vars.values.nameOverride)
end

def fullname(vars):
  name = vars.chart.name or vars.values.nameOverride
  return kube_clean_name("{}-{}".format(name, vars.chart.version))
end

def kube_clean_name(name):
  return name[:63].rstrip("-")
end
