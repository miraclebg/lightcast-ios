//
//  SSNetworkInfo.m
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SSNetworkInfo.h"

@implementation SSNetworkInfo

// Network Information

// Get Current IP Address
+ (NSString *)CurrentIPAddress {
    // Get the current IP Address
    
    // Check which interface is currently in use
    if ([self ConnectedToWiFi]) {
        // WiFi is in use
        
        // Get the WiFi IP Address
        NSString *WiFiAddress = [self WiFiIPAddress];
        
        // Check that you get something back
        if (WiFiAddress == nil || WiFiAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Wifi address
        return WiFiAddress;
    } else if ([self ConnectedToCellNetwork]) {
        // Cell Network is in use
        
        // Get the Cell IP Address
        NSString *CellAddress = [self CellIPAddress];
        
        // Check that you get something back
        if (CellAddress == nil || CellAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Cell address
        return CellAddress;
    } else {
        // No interface in use
        return nil;
    }
}

// Get Current MAC Address
+ (NSString *)CurrentMACAddress {
    // Get the current interface MAC Address
    
    // Check which interface is currently in use
    if ([self ConnectedToWiFi]) {
        // WiFi is in use
        
        // Get the WiFi MAC Address
        NSString *WiFiAddress = [self WiFiMACAddress];
        
        // Check that you get something back
        if (WiFiAddress == nil || WiFiAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Wifi address
        return WiFiAddress;
    } else if ([self ConnectedToCellNetwork]) {
        // Cell Network is in use
        
        // Get the Cell MAC Address
        NSString *CellAddress = [self CellMACAddress];
        
        // Check that you get something back
        if (CellAddress == nil || CellAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Cell address
        return CellAddress;
    } else {
        // No interface in use
        return nil;
    }
}

// Get Cell IP Address
+ (NSString *)CellIPAddress {
    // Get the Cell IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;
        
        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);
        
        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"pdp"])
                    {
                        // Get the WiFi IP Address
                        IPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Get Cell MAC Address
+ (NSString *)CellMACAddress {
    // Get the Cell MAC Address
    @try {
        // Start by setting the variables to get the Cell Mac Address
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex([@"pdp" UTF8String])) == 0)
            // Error, Name to index failure
            return nil;
        else
        {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
                // Error, Sysctl MgmtInfoBase Failure
                return nil;
            else
            {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL)
                    // Error, Buffer allocation failure
                    return nil;
                else
                {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                        // Error, Sysctl MsgBuffer Failure
                        return nil;
                }
            }
        }
        
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2],
                                      macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        // Make a new string from the macAddressString
        NSString *deviceID = macAddressString;
        
        // If the device ID comes back empty
        if (deviceID == (id)[NSNull null] || deviceID.length <= 0) {
            // Return that the MAC address was not found
            return nil;
        }
        
        // Return Successful
        return deviceID;
    }
    @catch (NSException *exception) {
        // Error, return nil
        return nil;
    }
}

// Get Cell Netmask Address
+ (NSString *)CellNetmaskAddress {
    // Get the Cell Netmask Address
    @try {
        // Set up the variable
        struct ifreq afr;
        // Copy the string
        strncpy(afr.ifr_name, [@"pdp" UTF8String], IFNAMSIZ-1);
        // Open a socket
        int afd = socket(AF_INET, SOCK_DGRAM, 0);
        
        // Check the socket
        if (afd == -1) {
            // Error, socket failed to open
            return nil;
        }
        
        // Check the netmask output
        if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
            // Error, netmask wasn't found
            // Close the socket
            close(afd);
            // Return error
            return nil;
        }
        
        // Close the socket
        close(afd);
        
        // Create a char for the netmask
        char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
        
        // Create a string for the netmask
        NSString *Netmask = [NSString stringWithUTF8String:netstring];
        
        // Check to make sure it's not nil
        if (Netmask == nil || Netmask.length <= 0) {
            // Error, netmask not found
            return nil;
        }
        
        // Return successful
        return Netmask;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Get Cell Broadcast Address
+ (NSString *)CellBroadcastAddress {
    // Get the Cell Broadcast Address
    @try {
        // Set up strings for the IP and Netmask
        NSString *IPAddress = [self CellIPAddress];
        NSString *NMAddress = [self CellNetmaskAddress];
        
        // Check to make sure they aren't nil
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Error, IP Address can't be nil
            return nil;
        }
        if (NMAddress == nil || NMAddress.length <= 0) {
            // Error, NM Address can't be nil
            return nil;
        }
        
        // Check the formatting of the IP and NM Addresses
        NSArray *IPCheck = [IPAddress componentsSeparatedByString:@"."];
        NSArray *NMCheck = [NMAddress componentsSeparatedByString:@"."];
        
        // Make sure the IP and NM Addresses are correct
        if (IPCheck.count != 4 || NMCheck.count != 4) {
            // Incorrect IP Addresses
            return nil;
        }
        
        // Set up the variables
        NSUInteger IP = 0;
        NSUInteger NM = 0;
        NSUInteger CS = 24;
        
        // Make the address based on the other addresses
        for (NSUInteger i = 0; i < 4; i++, CS -= 8) {
            IP |= [[IPCheck objectAtIndex:i] intValue] << CS;
            NM |= [[NMCheck objectAtIndex:i] intValue] << CS;
        }
        
        // Set it equal to the formatted raw addresses
        NSUInteger BA = ~NM | IP;
        
        // Make a string for the address
        NSString *BroadcastAddress = [NSString stringWithFormat:@"%d.%d.%d.%d", (int)((BA & 0xFF000000) >> 24),
                                      (int)((BA & 0x00FF0000) >> 16), (int)((BA & 0x0000FF00) >> 8), (int)(BA & 0x000000FF)];
        
        // Check to make sure the string is valid
        if (BroadcastAddress == nil || BroadcastAddress.length <= 0) {
            // Error, no address
            return nil;
        }
        
        // Return Successful
        return BroadcastAddress;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Get WiFi IP Address
+ (NSString *)WiFiIPAddress {
    // Get the WiFi IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;
        
        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);
        
        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"en0"])
                    {
                        // Get the WiFi IP Address
                        IPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Get WiFi MAC Address
+ (NSString *)WiFiMACAddress {
    // Get the WiFi MAC Address
    @try {
        // Start by setting the variables to get the WiFi Mac Address
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex([@"en0" UTF8String])) == 0)
            // Error, Name to index failure
            return nil;
        else
        {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
                // Error, Sysctl MgmtInfoBase Failure
                return nil;
            else
            {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL)
                    // Error, Buffer allocation failure
                    return nil;
                else
                {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                        // Error, Sysctl MsgBuffer Failure
                        return nil;
                }
            }
        }
        
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2],
                                      macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        // Make a new string from the macAddressString
        NSString *deviceID = macAddressString;
        
        // If the device ID comes back empty
        if (deviceID == (id)[NSNull null] || deviceID.length <= 0) {
            // Return that the MAC address was not found
            return nil;
        }
        
        // Return Successful
        return deviceID;
    }
    @catch (NSException *exception) {
        // Error, return nil
        return nil;
    }
}

// Get WiFi Netmask Address
+ (NSString *)WiFiNetmaskAddress {
    // Get the WiFi Netmask Address
    @try {
        // Set up the variable
        struct ifreq afr;
        // Copy the string
        strncpy(afr.ifr_name, [@"en0" UTF8String], IFNAMSIZ-1);
        // Open a socket
        int afd = socket(AF_INET, SOCK_DGRAM, 0);
        
        // Check the socket
        if (afd == -1) {
            // Error, socket failed to open
            return nil;
        }
        
        // Check the netmask output
        if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
            // Error, netmask wasn't found
            // Close the socket
            close(afd);
            // Return error
            return nil;
        }
        
        // Close the socket
        close(afd);
        
        // Create a char for the netmask
        char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
        
        // Create a string for the netmask
        NSString *Netmask = [NSString stringWithUTF8String:netstring];
        
        // Check to make sure it's not nil
        if (Netmask == nil || Netmask.length <= 0) {
            // Error, netmask not found
            return nil;
        }
        
        // Return successful
        return Netmask;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Get WiFi Broadcast Address
+ (NSString *)WiFiBroadcastAddress {
    // Get the WiFi Broadcast Address
    @try {
        // Set up strings for the IP and Netmask
        NSString *IPAddress = [self WiFiIPAddress];
        NSString *NMAddress = [self WiFiNetmaskAddress];
        
        // Check to make sure they aren't nil
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Error, IP Address can't be nil
            return nil;
        }
        if (NMAddress == nil || NMAddress.length <= 0) {
            // Error, NM Address can't be nil
            return nil;
        }
        
        // Check the formatting of the IP and NM Addresses
        NSArray *IPCheck = [IPAddress componentsSeparatedByString:@"."];
        NSArray *NMCheck = [NMAddress componentsSeparatedByString:@"."];
        
        // Make sure the IP and NM Addresses are correct
        if (IPCheck.count != 4 || NMCheck.count != 4) {
            // Incorrect IP Addresses
            return nil;
        }
        
        // Set up the variables
        NSUInteger IP = 0;
        NSUInteger NM = 0;
        NSUInteger CS = 24;
        
        // Make the address based on the other addresses
        for (NSUInteger i = 0; i < 4; i++, CS -= 8) {
            IP |= [[IPCheck objectAtIndex:i] intValue] << CS;
            NM |= [[NMCheck objectAtIndex:i] intValue] << CS;
        }
        
        // Set it equal to the formatted raw addresses
        NSUInteger BA = ~NM | IP;
        
        // Make a string for the address
        NSString *BroadcastAddress = [NSString stringWithFormat:@"%d.%d.%d.%d", (int)((BA & 0xFF000000) >> 24),
                                      (int)((BA & 0x00FF0000) >> 16), (int)((BA & 0x0000FF00) >> 8), (int)(BA & 0x000000FF)];
        
        // Check to make sure the string is valid
        if (BroadcastAddress == nil || BroadcastAddress.length <= 0) {
            // Error, no address
            return nil;
        }
        
        // Return Successful
        return BroadcastAddress;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Connected to WiFi?
+ (BOOL)ConnectedToWiFi {
    // Check if we're connected to WiFi
    NSString *WiFiAddress = [self WiFiIPAddress];
    // Check if the string is populated
    if (WiFiAddress == nil || WiFiAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // WiFi in use
        return true;
    }
}

// Connected to Cellular Network?
+ (BOOL)ConnectedToCellNetwork {
    // Check if we're connected to cell network
    NSString *CellAddress = [self CellIPAddress];
    // Check if the string is populated
    if (CellAddress == nil || CellAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // Cellular Network in use
        return true;
    }
}

@end
