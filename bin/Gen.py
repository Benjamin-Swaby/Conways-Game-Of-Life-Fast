import random as r

x = (0,0,1,1,1)

if __name__ == "__main__":

    directory = "./map.mp"
    numbers = int(input("Enter How Many Times: "))

    #can be changed later but I don't want it fucking up my source code
    with open(directory, "w+") as f:
        for i in range(numbers**2):
            f.write(str(r.choice(x)))
        f.close()
    
    print(f"Written {numbers**2} numbers to {directory}")
