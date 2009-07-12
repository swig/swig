printf("begin\n");
who global
empty
printf("after load\n");
who global

#clear -g
printf("after clear\n");
who global

#clear empty
printf("after clear specific\n");
who global

printf("before shutdown\n");
