terraform { 
  cloud { 
    
    organization = "quanth24" 

    workspaces { 
      name = "test-terraform" 
    } 
  } 
}

credentials "app.terraform.io" {
  token = "xxxxxx.atlasv1.zzzzzzzzzzzzz"
}
