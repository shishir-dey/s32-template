/*
 * NXP S32 Firmware Template
 * File: src/queue.c
 * Description: Generic queue implementation
 * Author: Shishir Dey
 * License: MIT
 */

#include "queue.h"

void queue_init(queue_t *q) {
    q->front = 0;
    q->rear = -1;
    q->count = 0;
}

int queue_is_full(queue_t *q) {
    return q->count == QUEUE_MAX_SIZE;
}

int queue_is_empty(queue_t *q) {
    return q->count == 0;
}

int queue_enqueue(queue_t *q, void *item) {
    if (queue_is_full(q)) {
        return -1;
    }
    q->rear = (q->rear + 1) % QUEUE_MAX_SIZE;
    q->data[q->rear] = item;
    q->count++;
    return 0;
}

int queue_dequeue(queue_t *q, void **item) {
    if (queue_is_empty(q)) {
        return -1;
    }
    *item = q->data[q->front];
    q->front = (q->front + 1) % QUEUE_MAX_SIZE;
    q->count--;
    return 0;
}