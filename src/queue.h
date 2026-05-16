/*
 * NXP S32 Firmware Template
 * File: src/queue.h
 * Description: Generic queue implementation
 * Author: Shishir Dey
 * License: MIT
 */

#ifndef QUEUE_H
#define QUEUE_H

#ifdef __cplusplus
extern "C" {
#endif

#define QUEUE_MAX_SIZE 10

typedef struct {
    void* data[QUEUE_MAX_SIZE];
    int front;
    int rear;
    int count;
} queue_t;

void queue_init(queue_t *q);
int queue_is_full(queue_t *q);
int queue_is_empty(queue_t *q);
int queue_enqueue(queue_t *q, void *item);
int queue_dequeue(queue_t *q, void **item);

#ifdef __cplusplus
}
#endif

#endif /* QUEUE_H */