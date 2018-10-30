FROM alpine

COPY --from=techservicesillinois/shibd-base /sha256sum.txt /tmp/sha256sum.base.txt
COPY --from=techservicesillinois/httpd-shibd-builder /base/sha256sum.txt /tmp/sha256sum.builder.txt

# Check for possiable race conditions during build
RUN diff /tmp/sha256sum.base.txt /tmp/sha256sum.builder.txt

##########################################

FROM techservicesillinois/shibd-base

COPY --from=techservicesillinois/httpd-shibd-builder /common/ /
