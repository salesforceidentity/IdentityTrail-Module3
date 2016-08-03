/**
  Registration Handler for External Identity Trail

**/ 
@isTest
public class Module3RegistrationHandler_Test {
    
    /**
     * Positive test for canCreateUser where all the required information is provided
     **/ 
    testmethod public static void testCanCreateUser() {
        Module3RegistrationHandler handler = new Module3RegistrationHandler();
        Auth.UserData data = createUser('test@example.com','John','Adams');
        
        System.Assert(handler.canCreateUser(data),'Handler should be able to create this user');
    }
    
    /**
     * Negative test for canCreateUser because insufficient detail is available
     **/     
    testmethod public static void testCanCreateUserNegative() {
        Module3RegistrationHandler handler = new Module3RegistrationHandler();
        Auth.UserData data = createUser(null,'Thomas','Jones-Drew');
        
        System.Assert(!handler.canCreateUser(data),'Handler should not be able to create user with missing email');
    }
    
    /**
     * Scenario where we want to provision an Internal User from Facebook
     **/ 
    testmethod public static void testCreateInternalUser() {
        Module3RegistrationHandler handler = new Module3RegistrationHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
        
        
        Test.startTest();
        
        User theUser = handler.createUser(null, data);
        
        Test.stopTest();
        
        validate(theUser,data);
        
    }
    
    /**
     * Scenario where we don't have enough detail to create a User end-to-end
     **/ 
    testmethod public static void testCreateInternalUserNegative() {
        Module3RegistrationHandler handler = new Module3RegistrationHandler();
        
        Auth.UserData data = createUser(null,'Thomas','Jones-Drew');
                
        Test.startTest();
        
        User theUser = handler.createUser(null, data);
        
        Test.stopTest();
        
        System.Assert(theUser==null,'User should be null for negative case');
        
    }
    
    /**
     * Simple direct test of the UpdateUser method.  Create the user first 
     * and then attempt to update some properties.
     **/ 
    testMethod public static void testUpdateUser() {
        Module3RegistrationHandler handler = new Module3RegistrationHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
        User theUser = handler.createUser(null, data);
        insert theUser;
        
        Test.startTest();
        
        validate(theUser,data);
        
        data.firstName='Tom';
        handler.updateUser(theUser.id, null, data);
        
        User theUpdatedUser = [SELECT Id,firstName,Email,LastName 
                                 from User 
                                Where Id = :theUser.id];
        
        validate(theUpdatedUser,data);
        
        Test.stopTest();

    }

    
    /**
     * Simple scenario to create a Community user
     **/ 
    testmethod public static void testCreateCommunityUser() {
        Module3RegistrationHandler handler = new Module3RegistrationHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
                
        Test.startTest();
        String theCommunityId = '00000001';
        data.attributeMap.put('sfdc_networkid',theCommunityId);
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        data.attributeMap.put('accountId',testAccount.id);
        
        User theUser = handler.createUser(null, data);
        
        Test.stopTest();
        
        validate(theUser,data);
        
        // Additional validations for Community User
        System.Assert(theUser.ContactId!=null,'Contact must be set for user');
        
    }
    
    /**
     * Helper method to Validate the the User we've created
     * 
     * @param theUser - the User that we created
     * @param data - the original AuthData supplied by FaceBook
     **/ 
    private static void validate(User theUser, Auth.UserData data) {
        System.Assert(theUser!=null,'User must not be null');
        System.AssertEquals(theUser.email,data.email,'Email address must be the same');
        System.AssertEquals(theUser.FirstName,data.FirstName,'First name must match');
        System.AssertEquals(theUser.LastName,data.LastName,'Last name must match');
    }

    
    /**
     * Helper method to instantiate the handler UserData
     * 
     * @param email
     * @param lastName
     * @param firstName
     * @return Auth.UserData that looks like what we expect from FaceBook
     **/ 
    private static Auth.UserData createUser(String email,String lastName, String firstName) {
         Map<String, String> attributeMap = new Map<String,String>();
         String identifier = lastName+System.currentTimeMillis();
         String locale = 'en_US';
         return new Auth.UserData( identifier,
               firstName,
               lastName,
              '', // fullname
               email,
               '', // link
               '', // userName
               locale,
               '', // provider
               '', // siteLoginUrl
               attributeMap);       
    }
}
