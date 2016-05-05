#import "XMPPMessage+Tools.h"
#import "NSFileManager+Tools.h"

@implementation XMPPMessage(Tools)

// 附件保存目录
- (NSString *)pathForAttachment:(NSString *)jid timestamp:(NSDate *)timestamp {
    // 创建缓存目录，目录名以chatJID
    NSString *path = [NSFileManager createDirInCachePathWithName:jid];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyyMMddHHmmss";
    NSString *fileName = [format stringFromDate:timestamp];
    path = [path stringByAppendingPathComponent:fileName];
    //NSLog(@"create dir: %@", path);
    return path;
}

// 保存附件
- (BOOL)saveAttachmentJID:(NSString *)jid timestamp:(NSDate *)timestamp {
    
    // 判断子节点数量,这里需要注意，只有voice和img才会有3个节点
    if (self.childCount == 3) {
        NSInteger index = -1;
        
        // 遍历所有节点
        for (XMPPElement *node in self.children) {
            // 如果节点的名称是attachment
            if ([node.name isEqualToString:@"attachment"]) {
                
                NSString *base64Str = node.stringValue;
                NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
                
                [data writeToFile:[self pathForAttachment:jid timestamp:timestamp] atomically:YES];
                NSLog(@"save attchment:%@", jid);
                // 记录附件节点的索引值
                index = node.index;
            }
        }
        
        // 如果index > 0，说明有附件，并且已经保存到磁盘
        if (index > 0) {
            // 使用索引，删除节点内容
            [self removeChildAtIndex:index];
            return YES;
        }
    }
    
    return NO;
}

- (MessageType)getMessageType {
    for (XMPPElement *node in self.children) {
        if ([node.name isEqualToString:MESSAGE_TYPE]) {
            if ([node.stringValue isEqualToString:VOICE]) {
                return MsgVoice;
            } else if ([node.stringValue isEqualToString:TEXT]) {
                return MsgText;
            } else {
                return MsgImage;
            }
        }
    }
    return MsgText;
}

@end
