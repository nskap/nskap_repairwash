Config = {}

Config.RepairItem = 'repairkit'
Config.WashItem = 'sponge'

Config.ConsumeOnSuccess = true


Config.RepairDuration = 8000
Config.WashDuration = 5000


Config.RequireOnFoot = true

Config.MinEngineHealthForRepair = 900.0 -- you can only repair vehicles with engine health lower than this value

Config.RepairAlways = true -- if true, you can repair any vehicle, even if it's not damaged

Config.CleanOnRepair = false

Config.JobRequired = true
Config.AllowedJobs = { 'mechanic' } --{ 'lsc', 'bennys' }


Config.Target = {
distance = 2.0,
repair = { icon = 'fa-solid fa-wrench', label = 'Opravit vozidlo' },
wash = { icon = 'fa-solid fa-soap', label = 'Umyt vozidlo' }
}


Config.Anims = Config.Anims or {
  repair = {
    type = 'dict',
    dict = 'mini@repair',
    clip = 'fixing_a_ped',
    duration = 7000,
    flag = 49
  },
  wash = {
    type = 'dict',
    dict = 'amb@world_human_maid_clean@',
    clip = 'base',
    duration = 7000,
    flag = 49
  }
}
