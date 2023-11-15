module util.linkedlist;

import util.memc;

struct LinkedList(T) {
    struct Node {
        T data;
        Node* next;
    }

    size_t length;
    Node* head;

    ~this() {
        Node* curr = head;
        while (curr) {
            Node* next = curr.next;
            free(curr);
            curr = next;
        }
    }

    ref T opIndex(size_t ind) {
        assert(ind < length);

        Node* curr = head;
        while (ind--)
            curr = curr.next;
        return curr.data;
    }

    int opApply(scope int delegate(ref T) dg) {
        Node* curr = head;
        foreach (i; 0 .. length) {
            if (int res = dg(curr.data))
                return res;
            curr = curr.next;
        }
        return 0;
    }

    void push(T item) {
        Node* node = malloc!Node();
        *node = Node(item, head);
        head = node;
        length++;
    }

    T pop() {
        assert(length);
        Node* old = head;
        T data = head.data;
        head = head.next;
        free(old);
        length--;
        return data;
    }
}