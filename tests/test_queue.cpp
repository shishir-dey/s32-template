/*
 * NXP S32 Firmware Template
 * File: tests/test_queue.cpp
 * Description: Sample unit test
 * Author: Shishir Dey
 * License: MIT
 */

#include "gtest/gtest.h"
#include "queue.h"

TEST(QueueTest, Init) {
    queue_t q;
    queue_init(&q);
    EXPECT_EQ(q.count, 0);
    EXPECT_EQ(q.front, 0);
    EXPECT_EQ(q.rear, -1);
}

TEST(QueueTest, IsEmpty) {
    queue_t q;
    queue_init(&q);
    EXPECT_TRUE(queue_is_empty(&q));
}

TEST(QueueTest, IsFull) {
    queue_t q;
    queue_init(&q);
    EXPECT_FALSE(queue_is_full(&q));
}

TEST(QueueTest, Enqueue) {
    queue_t q;
    queue_init(&q);
    int item = 1;
    EXPECT_EQ(queue_enqueue(&q, &item), 0);
    EXPECT_EQ(q.count, 1);
    EXPECT_EQ(q.rear, 0);
}

TEST(QueueTest, Dequeue) {
    queue_t q;
    queue_init(&q);
    int item = 1;
    queue_enqueue(&q, &item);
    void *dequeued_item;
    EXPECT_EQ(queue_dequeue(&q, &dequeued_item), 0);
    EXPECT_EQ(dequeued_item, &item);
    EXPECT_EQ(q.count, 0);
    EXPECT_EQ(q.front, 1);
}

TEST(QueueTest, EnqueueDequeue) {
    queue_t q;
    queue_init(&q);
    int item1 = 1;
    int item2 = 2;
    queue_enqueue(&q, &item1);
    queue_enqueue(&q, &item2);
    void *dequeued_item;
    queue_dequeue(&q, &dequeued_item);
    EXPECT_EQ(dequeued_item, &item1);
    queue_dequeue(&q, &dequeued_item);
    EXPECT_EQ(dequeued_item, &item2);
}

TEST(QueueTest, Full) {
    queue_t q;
    queue_init(&q);
    for (int i = 0; i < QUEUE_MAX_SIZE; i++) {
        int *item = new int(i);
        queue_enqueue(&q, item);
    }
    EXPECT_TRUE(queue_is_full(&q));
    int *item = new int(10);
    EXPECT_EQ(queue_enqueue(&q, item), -1);
}

TEST(QueueTest, Empty) {
    queue_t q;
    queue_init(&q);
    void *dequeued_item;
    EXPECT_EQ(queue_dequeue(&q, &dequeued_item), -1);
}
