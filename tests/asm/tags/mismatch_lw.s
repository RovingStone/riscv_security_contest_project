#include <defines.S>
#include <boot.S>

.text
main:
    li a0, TAG_CTRL_ENABLE
    csrw tags, a0

    li t1, TAG_V3
    li t2, TAG_V8

    // load addresses we want to tag
    la a0, tagged1
    la a1, tagged2

    // set tags
    st t1, 0(a0)
    st t2, 0(a1)

    // now a0 contains address with wrong tag set
    SET_TAG(a0, t6, t2)
    lw t0, 8(a0)

    FAILED 1

.balign 16
tagged1:
.8byte 0xdeadbeefbeefdead
.8byte 0xbaddeaddeadbad
.balign 16
tagged2:
.8byte 0xdeadbeefbeefdead
.8byte 0xbaddeaddeadbad

ON_EXCEPTION:
    PASSED
