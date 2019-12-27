clc;
clear all;
img=imread('1.bmp');  
R=img(:,:,1);           %��ȡ��ɫͼ���rֵ��
G=img(:,:,2);           %��ȡ��ɫͼ���gֵ��
B=img(:,:,3);           %��ȡ��ɫͼ���bֵ��
I2=rgb2gray(img);       %��ͼ��ҶȻ���
figure,imshow(I2),title('�Ҷ�ͼ��');
BW=im2bw(I2,0.9);       %��ͼ���ֵ����

SE=strel('rectangle',[40 30]);      % �ṹ����
J2=imopen(BW,SE);                   % ���п�����ȥ��������ƽ���߽�
figure,imshow(J2),title('�Զ�ֵͼ����п������Ľ��ͼ��');
SE=strel('square',3);               % ����3��3��ʴ�ṹԪ��
J=imerode(~J2,SE);                  %��ͼ����и�ʴ������
BW2=(~J2)-J;                         % ����Ե


%��������еļ���������״�߽�
B = imfill(BW2,'holes');            %��ͼ�����׶���
B = bwmorph(B,'remove');            %���ͼ��������߽硣


%����ͬ��ͼ�ν��зֱ��ǣ�num��ʾ���ӵ�ͼ�ζ���ĸ���
[Label,num] = bwlabel(B);           %���б�ǡ�
for i = 1 : num
    Area(i) = 0;
end
Label = imfill(Label,'holes');       %�������ǵı߽����м�Χ�ɵ�ͼ������


%�������ͼ���hsv��ɫ��ɫ�ȣ�

HSV = rgb2hsv(img);                  %ת��ΪHSV��ɫģ�͡�

[row,col] = size(Label);             %ͳ�������ͼ���и���ͼ���������صĸ����Ķ���
MeanHue = zeros(1,num);             %��ʼ��
    for i = 1 : num
        Hue = zeros(Area(i),1);     %��ʼ��
        nPoint = 0;                 %��ʼ��
        for j = 1 : row
            for k = 1 : col
                if(Label(j,k) == i)
                    nPoint = nPoint + 1;            %��������ͨ�����еĵ�npoint+1.
                    Hue(nPoint,1) = HSV(j,k,1);     %��hsv��ֵ����Hue���顣
                end
            end
        end
        
        Hue(:,i) = sort(Hue(:,1));
        for j = floor(nPoint*0.1) : floor(nPoint*0.9)
            MeanHue(i) = MeanHue(i) + Hue(j,1);     %��hsv(i)��ֵ����MeanHue(i)
        end
        MeanHue(i) = MeanHue(i) / (0.8*nPoint);     %�����ƽ����ɫ��ֵ
    end

%����regionprops������ø�����ͨ���������ֵ(���ĵ����꣬�����Բ�ĳ����᳤�ȣ����)��
[L,num]=bwlabel(BW2);                               %���½��������ǡ�
stats= regionprops(L, 'ALL');                       %����regionprops������
for i= 1:num
longth(i)=stats(i).MajorAxisLength;                 %��������Բ�ĳ��᳤��
width(i)=stats(i).MinorAxisLength;                  %��������Բ�Ķ��᳤��
end
%��ʼ����
R2=0;
G2=0;
B2=0;
x=0;
y=0;
%�����Բ�ԡ�
for i=1:num
    r(i)=0;
    g(i)=0;
    b(i)=0;
    yuan(i)=longth(i)/width(i);%���᳤��/���᳤��Ϊ��Բ��������
end

%�����ÿ��ˮ������Ϊ���ĵ�ı߳�Ϊ30���������ڵ����ص�rgbֵ
for i=1:num
    for j=(round(stats(i).Centroid(1))-15):(round(stats(i).Centroid(1))+15)
        for k=(round(stats(i).Centroid(2))-15):(round(stats(i).Centroid(2))+15)
            R2=im2double(img(j,k,1));
            G2=im2double(img(j,k,2));
            B2=im2double(img(j,k,3));
            r(i)=r(i)+R2;
            g(i)=g(i)+G2;
            b(i)=b(i)+B2;
        end
    end
    r(i)=r(i)/900;
    g(i)=g(i)/900;
    b(i)=b(i)/900;
end

%���ˮ����������ֵ�����ж�
for i=1:num
    if(stats(i,1).Area>x)
        x=stats(i,1).Area;
    end
end

%���ˮ����hsv����Сֵ�����ж�
y=MeanHue(1);
for i=1:num
    if(y>MeanHue(i))
        y=MeanHue(i);
    end
end



%��ʾ���շ�����ͼ��
figure,imshow(img);

%���ӷ����㷨
for i=1:num
    if(MeanHue(i)==y && yuan(i)>1.3 && r(i)>0.7 && g(i)>0.7)
        text(stats(i).Centroid(1),stats(i).Centroid(2),'ˮ���������');
    end
end

%ƻ�������㷨
for i=1:num
    if(r(i)>0.75 && yuan(i)<1.15  && g(i)<0.4 && b(i)<0.3)
         text(stats(i).Centroid(1),stats(i).Centroid(2),'ˮ�����ƻ��');
    end
end

%���ӷ����㷨
for i=1:num
    if(MeanHue(i)<0.6 && yuan(i)<1.25 && r(i)>0.7 &&b(i)>0.1)
        text(stats(i).Centroid(1),stats(i).Centroid(2),'ˮ���������');
    end
end

%�㽶�����㷨
for i=1:num
    if(MeanHue(i)<0.2 && yuan(i)>1.7)
         text(stats(i).Centroid(1),stats(i).Centroid(2),'ˮ������㽶');
    end
end

%���ܷ����㷨
for i=1:num
    if(MeanHue(i)<0.3 && yuan(i)>1.4&& r(i)<0.8 )
        text(stats(i).Centroid(1)+30,stats(i).Centroid(2)+30,'ˮ����𣺲���');
    end
end

%���Ϸ����㷨
for i=1:num
    if( stats(i,1).Area==x && yuan(i)<1.25&& r(i)<0.4)
        text(stats(i).Centroid(1),stats(i).Centroid(2),'ˮ���������');
    end
end

