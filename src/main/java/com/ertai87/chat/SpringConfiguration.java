package com.ertai87.chat;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.*;

@Configuration
public class SpringConfiguration {

    @Bean
    public Map<String, Queue<ChatEntry>> data(){
        return new HashMap<>();
    }

    @Bean
    public Map<String, Boolean> locks(){
        return new HashMap<>();
    }

    @Bean
    public MessageQueueMap messageQueueMap(){
        return new MessageQueueMap();
    }
}
