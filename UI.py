#Sean Novak
#11-3-2020
#Simple Python UI for SQL shopping database "onlinePurchasedb"

#This UI accesses data from the "onlinePurchasedb" database found in main.sql
#INSERT USERNAME, PASSWORD AND HOST ON LINE 11 BEFORE RUNNING!

import pymysql
from datetime import datetime
#autommit needs to be set to true or cnx.commit() called before closing shell for data minipulation to work
cnx = pymysql.connect(user = '', password = '', host='', database = 'onlinepurchasedb', autocommit = False)

crs = cnx.cursor() #creating a cursor to be used by the whole program

def newUser():
    #insert info into customer table
    query = "select max(customer_ID) from customer;" #putting together the query
    crs.execute(query)  #exucute the query
    custID = str((int(crs.fetchone()[0]) + 1)) #takes the highest customer ID and adds 1 to it and casts the whole thing as a string, gives a unique ID every time

    query = "select max(address_ID) from address;" #putting together the query
    crs.execute(query)  #exucute the query
    addressID = str((int(crs.fetchone()[0]) + 1)) #takes the highest customer ID and adds 1 to it and casts the whole thing as a string, gives a unique ID every time
    
    fName = input("First name: ")
    lName = input("Last name: ")
    dBirth = input("Day of birth (yyyy-mm-dd): ")

    query = "insert into customer values (" + custID + "," + addressID + ",'" + fName + "','" + lName + "','" + dBirth + "');" #putting together the query
    crs.execute(query)  #exucute the query

    #insert info into the customeraddress table

    country = input("What country do you live in?: ")
    state = input("State: ")
    city = input("City: ")
    street = input("Street: ")
    zipCode = input("Zipcode: ")

    query = "insert into address values ('" + addressID + "','" + street + "','" + city + "','" + zipCode + "','" + state + "','" + country + "');"
    crs.execute(query)

    #insert into bankinfo table
    while True: #Make sure they can add as many accounts as they want
        account_num = input("Bank account number(type as many as needed, -1 when finished): ")
        if account_num == "-1":
            break
        bank_name = input("Bank name: ")
        
        query = "insert into bankinfo values ('" + custID + "','" + account_num + "','" + bank_name + "');"
        crs.execute(query)



    #insert into accountinfo table
    userID = input("Please create a Username: ")
    password = input("Please create a password (max 15 characters): ")

    query = "insert into userinfo values ('" + custID + "','" + userID+ "','" + password + "');"
    crs.execute(query)
    
    cnx.commit() #commit all above changes to the db

def signIn():

    print("\nPlease sign in to your account:")

    position = "none"
    while position == "none": #Allows the user to attempt sign in multiple times

        userID = input("\nUserID: ")
        password = input("Password: ")

        query = "select * from manager where userID = '" + userID + "' and password = '" + password + "';" #search for the given userID and password in the manager table
        isManager = crs.execute(query) 
        if isManager == 1: #If it is found there will be one item found
            position = "Manager"

        query = "select * from userinfo where userID = '" + userID + "' and password = '" + password + "';" #search for the given userID and password in the customer table
        isCust = crs.execute(query)
        if isCust == 1:
            position = "Customer"

        else:
            print("Invalid UserID or Password")

    return position

def printItems():
    query = "select * from items" #grab everything in the items table
    resultCount = crs.execute(query)

    print('{:<15s}{:<20s}{:<15s}{:<15s}{:<15s}'.format( "ID", "Name", "Stock", "Price", "Discount") )  #Section headers formatted to be in a grid
    print("===============================================================================")        #Just a line to make it look pretty
    
    ct=0
    while ct < resultCount: #Make sure it only runs for the length of table
        ct+=1
        res=crs.fetchone() #fetch the next row from the query
        print('{:<15d}{:<20s}{:<15d}{:<15f}{:<15f}'.format( res[0], res[1], res[2], res[3], res[4] ) ) #print the information from the current row formatted to be aligned as a grid

def printBillHistory(custID):
    query = "select account_num, date, total_price, discount from billing where customer_ID = " + str(custID) + ";" #grab selected columns in the billing table
    resultCount = crs.execute(query)

    print('{:<15s}{:<15s}{:<15s}{:<15s}'.format( "Account", "Date", "Total", "Discount") )  #Section headers formatted to be in a grid
    print("===============================================================")                #just a line to make it look pretty

    ct=0
    while ct < resultCount: #Make sure it only runs for the length of table
        ct+=1
        res=crs.fetchone() #fetch the next row from the query
        print('{:<15d}{:<15s}{:<15f}{:<15f}'.format( res[0], str(res[1]), res[2], res[3]) ) #print the information from the current row formatted to be aligned as a grid

def customer(custID):
    print("Acccess granted\n")

    printItems()

    total = 0.00
    discount_total = 0.00
    itemID = 1
    quantity = 0
    itemsBought = []    #An array that stores all the items bought over the course of the transaction
    quantities = []     #An array that stores the quantities the items bought over the course of the transaction

    while True:
        #let the user choose items to buy
        itemID = input("\nPlease type an itemID(-1 to finish): ")
        if itemID == "-1":
            break

        query = "select * from items where item_ID = " + itemID + ";" #Search for the item given in the table items
        resultCount = crs.execute(query)


        if(resultCount == 1): #one result will be found if it is there
            stock = int(crs.fetchone()[2]) #get the remaining stock of the item

            if stock > 0:
                quantity = int(input("Quantity: "))

                if quantity <= stock:
                    itemsBought.append(itemID) #add the itemID to the itemsBought array
                    quantities.append(quantity) #Add the quantity to the quantities array

                    crs.execute(query) #reset the fetchone() function
                    price = float(crs.fetchone()[3]) #fetch the third column of the query (price), cast as a float
                    crs.execute(query) #reset the fetchone() function
                    discount = float(crs.fetchone()[4]) #fetch the fourth column of the query (discount), cast as a float

                    total += ((price - discount) * quantity) #Add to the total taking into account the discount and number of items bought
                    discount_total += (discount * quantity) #Keep track of the total amount discounted

                    query = "update items set stock = " + str(stock - quantity) +" where item_ID = " + itemID + ";" #reduce the stock of the item by the quantity bought
                    crs.execute(query)

                else:
                    print("Not enough stock")

            else:
                print("out of stock")

        else:
            print("Unknown ID")


    #create billID
    query = "select max(bill_ID) from billing;" 
    crs.execute(query)
    billID = (int(crs.fetchone()[0]) + 1)       #takes the highest customer ID, casts it as and int and adds 1 to it

    accountNum = input("\nType the number of the account you would like to use: ")

    date = datetime.today().strftime('%Y-%m-%d') #gives today's date in year-month-day order. don't ask me how it works it just does

    query = "insert into billing values (" + str(billID) + "," + str(custID) + "," + accountNum + ",'" + date + "'," + str(total) + ", " + str(discount_total) + " );"
    crs.execute(query)

    ct = 0
    while ct < len(itemsBought): #add an entry for every item selected
        #Each entry in quantities should correspond to the same index in itemsBought since every entry was added simultaneously
        query = "insert into itemsbought values (" + str(billID) + "," + itemsBought[ct] + "," + str(quantities[ct]) + " );"    
        crs.execute(query)
        ct += 1

    print("\nYour total is ", total)

    confirm = "0"
    while confirm != "y" and confirm != "n": #stay in the loop until they type y or n
        confirm = input("Complete the transaction?(y/n): ")

    if confirm == "y":
        cnx.commit() #commit the changes to the db
        print("\nTransaction complete!")

    else:
        print("Transaction cancelled") #no commit


    confirm = "0"
    while confirm != "y" and confirm != "n": #stay in the loop until they type y or n
        confirm = input("Would you like to see your bill history?(y/n): ")


    if confirm == "y":
        printBillHistory(custID)

def printAvgBills():
    query = "select * from avgBillsPerZip;"
    resultCount = crs.execute(query)

    print('{:<15s}{:<15s}'.format( "Average", "Zip Code") )  #Section headers formatted to be in a grid
    print("================================")                 #Just a line to make it look pretty

    ct=0
    while ct < resultCount: #Make sure it only runs for the length of table
        ct+=1
        res=crs.fetchone() #fetch the next row from the query
        print('{:<15f}{:<15d}'.format( res[0], res[1] ) ) #print the information from the current row formatted to be aligned as a grid
        
def printRecentTransaction():
    query = "select * from currentBills;"
    resultCount = crs.execute(query)

    print('{:<10s}{:<15s}{:<10s}{:<15s}{:<10s}{:<10s}'.format("BillID", "CustomerID", "Account", "Date", "Total", "Discount") )  #Section headers formatted to be in a grid
    print("=========================================================================")                       #Just a line to make it look pretty

    ct=0
    while ct < resultCount: #Make sure it only runs for the length of table
        ct+=1
        res=crs.fetchone() #fetch the next row from the query
        #print the information from the current row formatted to be aligned as a grid, 3 was casted as a string for compatibility
        print('{:<10d}{:<15d}{:<10d}{:<15s}{:<10f}{:<10f}'.format( res[0], res[1], res[2], str(res[3]), res[4], res[5]) ) 

def manager(): #manaagers get to see average bills per zip code and recent transactions
    print("\nWelcome Manager!\n\nAverage bills per Zip Code:")

    printAvgBills()

    print("\nRecent transactions:")

    printRecentTransaction()

def accessSystem(position):

    if position == "Customer":      #if there was an account found
        custID = crs.fetchone()[0]  #store the first column of the query (customer_ID)
        customer(custID)
        
    elif position == "Manager":
        manager()

def checkIfNew():
    isNew = "0"

    while isNew != "y" and isNew != "n": #stay in the loop until they type y or n
        isNew = input("Are you new?(y/n): ")

    if isNew == "y":
        newUser()
        print("Account creation successful!")

def main():
    checkIfNew()

    position = signIn()

    accessSystem(position)
    print ("\ngoodbye!")

main()

