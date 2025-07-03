# Setting up tfvars so I can have constant values that Github Actions will see and use automatically
region = "us-east-1"
ami_id = "ami-0c02fb55956c7d316"
active_env = "blue" # Sets the stack we want to use between Blue and Green
create_alb = true # Decides where or not to create an ALB if not it's not already created
#user_name = [] # Blank when we're not creating new users
user_name = ["Zordon", "Alpha", "Jason", "Kimberly", "Trini", "Zack"]
existing_users = ["xfsUser"]
/*existing_users = [ 
    "Zordon", 
    "Alpha", 
    "Jason", 
    "Kimberly", 
    "Trini", 
    "Zack" 
    ]*/