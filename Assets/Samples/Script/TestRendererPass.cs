using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class TestRendererPass : ScriptableRenderPass
{
    private Material m_material;
    private int m_textureId;
    private int m_grabTexSizeId;
    private RenderTargetIdentifier m_currentTarget;

    public TestRendererPass(Shader shader, string textureName, RenderPassEvent renderPassEvent)
    {
        this.m_material = new Material(shader);
        this.m_textureId = Shader.PropertyToID(textureName);
        this.m_grabTexSizeId = Shader.PropertyToID("_GrabTexSize");
        this.renderPassEvent = renderPassEvent;
    }

    public void SetRenderTarget(RenderTargetIdentifier target)
    {
        this.m_currentTarget = target;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        var cameraData = renderingData.cameraData;
        var buf = CommandBufferPool.Get(nameof(TestRendererPass));
        int w = cameraData.camera.scaledPixelWidth;
        int h = cameraData.camera.scaledPixelHeight;
        buf.GetTemporaryRT(m_textureId, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        buf.Blit(m_currentTarget, m_textureId);
        buf.SetGlobalVector(m_grabTexSizeId, new Vector4(1.0f / (float)w, 1.0f / (float)h));
        buf.Blit(m_textureId, m_currentTarget, m_material);
        context.ExecuteCommandBuffer(buf);
        CommandBufferPool.Release(buf);
    }
}
